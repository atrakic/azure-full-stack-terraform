#!/usr/bin/env bash

set -eo pipefail

URI=${URI:-http://localhost:8000/api}

declare -a opts
opts=(
  -fiskL
  -H 'Cache-Control: no-cache, no-store'
  -H 'Accept: application/json'
)

[ -n "$API_TOKEN" ] && opts+=( -H "Authorization: Bearer '$API_TOKEN'" )

## REST
curl "${opts[@]}" "${URI}" #| jq -r "."
