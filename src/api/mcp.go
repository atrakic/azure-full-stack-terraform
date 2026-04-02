package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

// ── Minimal OpenAPI 2.0 types ────────────────────────────────────────────────

type swaggerDoc struct {
	BasePath string                        `json:"basePath"`
	Paths    map[string]map[string]swagOp  `json:"paths"`
}

type swagOp struct {
	OperationID string      `json:"operationId"`
	Summary     string      `json:"summary"`
	Description string      `json:"description"`
	Parameters  []swagParam `json:"parameters"`
}

type swagParam struct {
	Name        string      `json:"name"`
	In          string      `json:"in"`
	Description string      `json:"description"`
	Required    bool        `json:"required"`
	Type        string      `json:"type"`
}

// ── MCP JSON-RPC types ───────────────────────────────────────────────────────

type mcpRequest struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      int             `json:"id"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params,omitempty"`
}

type mcpResponse struct {
	JSONRPC string      `json:"jsonrpc"`
	ID      int         `json:"id"`
	Result  interface{} `json:"result,omitempty"`
	Error   *mcpError   `json:"error,omitempty"`
}

type mcpError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

// opMeta maps tool name → (http method, path)
type opMeta struct {
	method string
	path   string
}

var (
	mcpTools  []map[string]interface{}
	mcpOpMeta map[string]opMeta // name → REST call details
)

func loadOpenAPITools(specPath string) {
	data, err := os.ReadFile(specPath)
	if err != nil {
		return // spec not ready yet; tools stay empty
	}
	var doc swaggerDoc
	if err := json.Unmarshal(data, &doc); err != nil {
		return
	}

	mcpOpMeta = make(map[string]opMeta)

	for path, methods := range doc.Paths {
		for httpMethod, op := range methods {
			name := op.OperationID
			if name == "" {
				// fallback: "get_api_v1" from "GET /api/v1"
				name = strings.ToLower(httpMethod) + "_" + strings.NewReplacer("/", "_", "{", "", "}", "").Replace(path)
				name = strings.Trim(name, "_")
			}

			desc := op.Summary
			if op.Description != "" {
				desc = op.Description
			}

			// Build inputSchema from query/path parameters
			props := map[string]interface{}{}
			required := []string{}
			for _, p := range op.Parameters {
				if p.In == "query" || p.In == "path" {
					props[p.Name] = map[string]string{
						"type":        p.Type,
						"description": p.Description,
					}
					if p.Required {
						required = append(required, p.Name)
					}
				}
			}
			schema := map[string]interface{}{"type": "object"}
			if len(props) > 0 {
				schema["properties"] = props
			}
			if len(required) > 0 {
				schema["required"] = required
			}

			mcpTools = append(mcpTools, map[string]interface{}{
				"name":        name,
				"description": desc,
				"inputSchema": schema,
			})
			mcpOpMeta[name] = opMeta{method: strings.ToUpper(httpMethod), path: path}
		}
	}
}

func callOpenAPI(name string, args map[string]interface{}) (string, error) {
	meta, ok := mcpOpMeta[name]
	if !ok {
		return "", fmt.Errorf("no OpenAPI operation for tool: %s", name)
	}

	// Substitute path params, collect query params
	path := meta.path
	queryParts := []string{}
	for k, v := range args {
		placeholder := "{" + k + "}"
		if strings.Contains(path, placeholder) {
			path = strings.ReplaceAll(path, placeholder, fmt.Sprintf("%v", v))
		} else {
			queryParts = append(queryParts, fmt.Sprintf("%s=%v", k, v))
		}
	}
	if len(queryParts) > 0 {
		path += "?" + strings.Join(queryParts, "&")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}
	url := "http://localhost:" + port + path

	resp, err := http.Get(url) //nolint:noctx
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)

	// Pretty-print if JSON
	var v interface{}
	if json.Unmarshal(body, &v) == nil {
		if pretty, err := json.MarshalIndent(v, "", "  "); err == nil {
			return string(pretty), nil
		}
	}
	return string(body), nil
}

// ── Handler ──────────────────────────────────────────────────────────────────

// @Summary MCP JSON-RPC endpoint
// @Description Exposes OpenAPI operations as MCP tools, auto-generated from swagger.json.
// @Accept json
// @Produce json
// @Param request body mcpRequest true "MCP JSON-RPC request"
// @Success 200 {object} mcpResponse
// @Router /mcp [post]
func mcpHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var req mcpRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	resp := mcpResponse{JSONRPC: "2.0", ID: req.ID}

	switch req.Method {
	case "initialize":
		resp.Result = map[string]interface{}{
			"protocolVersion": "2024-11-05",
			"serverInfo":      map[string]string{"name": "sysinfo-mcp", "version": "1.0.0"},
			"capabilities":    map[string]interface{}{"tools": map[string]bool{"listChanged": false}},
		}

	case "tools/list":
		resp.Result = map[string]interface{}{"tools": mcpTools}

	case "tools/call":
		var params struct {
			Name      string                 `json:"name"`
			Arguments map[string]interface{} `json:"arguments"`
		}
		if err := json.Unmarshal(req.Params, &params); err != nil {
			resp.Error = &mcpError{Code: -32602, Message: "invalid params"}
			break
		}
		text, err := callOpenAPI(params.Name, params.Arguments)
		if err != nil {
			resp.Error = &mcpError{Code: -32601, Message: err.Error()}
			break
		}
		resp.Result = map[string]interface{}{
			"content": []map[string]interface{}{
				{"type": "text", "text": text},
			},
		}

	default:
		resp.Error = &mcpError{Code: -32601, Message: "method not found: " + req.Method}
	}

	json.NewEncoder(w).Encode(resp)
}
