#!/usr/bin/env bash

set -eo pipefail

URI=${URI:-http://localhost:8000/api/}

declare -a opts
opts=(
  -fiskL
  -H 'Cache-Control: no-cache, no-store'
  -H 'Accept: application/json'
)

[ -n "$API_TOKEN" ] && opts+=( -H "Authorization: Bearer '$API_TOKEN'" )

## REST
curl "${opts[@]}" "${URI}" #| jq -r "."

# MCP test
curl -s -X POST "${URI}"/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | jq

# MCP test
curl -s -X POST "${URI}"/mcp -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get__v1","arguments":{}}}' | jq # | python3 -m json.tool
