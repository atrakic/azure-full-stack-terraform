package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
)

// OpenAPI spec types (mirrors mcp.go on the server side)
type swaggerDoc struct {
	Paths map[string]map[string]struct {
		OperationID string `json:"operationId"`
		Summary     string `json:"summary"`
	} `json:"paths"`
}

// toolName derives a tool name from an OpenAPI operation — identical logic to mcp.go.
func toolName(method, path, operationID string) string {
	if operationID != "" {
		return operationID
	}
	name := strings.ToLower(method) + "_" + strings.ReplaceAll(path, "/", "_")
	return strings.TrimPrefix(name, "_")
}

// fetchSpec downloads and parses the OpenAPI spec from the given URL.
func fetchSpec(specURL string) (*swaggerDoc, error) {
	resp, err := http.Get(specURL)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	var doc swaggerDoc
	return &doc, json.Unmarshal(data, &doc)
}

// MCP JSON-RPC helpers

type mcpRequest struct {
	JSONRPC string      `json:"jsonrpc"`
	ID      int         `json:"id"`
	Method  string      `json:"method"`
	Params  interface{} `json:"params,omitempty"`
}

type mcpResponse struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      int             `json:"id"`
	Result  json.RawMessage `json:"result,omitempty"`
	Error   *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error,omitempty"`
}

func call(endpoint, method string, params interface{}) (json.RawMessage, error) {
	body, _ := json.Marshal(mcpRequest{JSONRPC: "2.0", ID: 1, Method: method, Params: params})
	resp, err := http.Post(endpoint, "application/json", bytes.NewReader(body))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	var rpc mcpResponse
	if err := json.NewDecoder(resp.Body).Decode(&rpc); err != nil {
		return nil, err
	}
	if rpc.Error != nil {
		return nil, fmt.Errorf("rpc error %d: %s", rpc.Error.Code, rpc.Error.Message)
	}
	return rpc.Result, nil
}

func pretty(raw json.RawMessage) string {
	var v interface{}
	json.Unmarshal(raw, &v)
	b, _ := json.MarshalIndent(v, "", "  ")
	return string(b)
}

func main() {
	// Base URL for the stack (nginx). MCP lives at /api/mcp, spec at /docs/swagger.json.
	base := os.Getenv("BASE_URL")
	if base == "" {
		base = "http://localhost:8000"
	}
	mcpEndpoint := base + "/api/mcp"
	specURL := base + "/docs/swagger.json"

	// 1. Fetch OpenAPI spec — source of truth for tool discovery.
	fmt.Printf("=== fetching OpenAPI spec: %s ===\n", specURL)
	doc, err := fetchSpec(specURL)
	if err != nil {
		log.Fatalf("fetch spec: %v", err)
	}

	// 2. Derive tool list from spec (same logic as mcp.go), skipping /mcp itself.
	type toolEntry struct{ name, path, method string }
	var tools []toolEntry
	for path, methods := range doc.Paths {
		if path == "/mcp" {
			continue // skip the MCP handler to avoid recursion
		}
		for method, op := range methods {
			tools = append(tools, toolEntry{
				name:   toolName(method, path, op.OperationID),
				path:   path,
				method: method,
			})
		}
	}
	fmt.Printf("Discovered %d tool(s) from spec:\n", len(tools))
	for _, t := range tools {
		fmt.Printf("  %s  (%s %s)\n", t.name, strings.ToUpper(t.method), t.path)
	}

	// 3. MCP initialize handshake.
	fmt.Printf("\n=== initialize (%s) ===\n", mcpEndpoint)
	res, err := call(mcpEndpoint, "initialize", nil)
	if err != nil {
		log.Fatalf("initialize: %v", err)
	}
	fmt.Println(pretty(res))

	// 4. Call each tool discovered from the spec.
	callArgs := map[string]interface{}{}
	if len(os.Args) > 1 {
		callArgs["key"] = os.Args[1]
	}
	for _, t := range tools {
		res, err = call(mcpEndpoint, "tools/call", map[string]interface{}{
			"name":      t.name,
			"arguments": callArgs,
		})
		if err != nil {
			log.Printf("tools/call %s: %v", t.name, err)
			continue
		}
		fmt.Printf("\n=== tools/call %s ===\n", t.name)
		fmt.Println(pretty(res))
	}
}
