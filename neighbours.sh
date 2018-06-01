#!/bin/bash
curl -sH 'X-IOTA-API-VERSION: 1.4' -d '{"command":"getNeighbors"}' http://127.0.0.1:14264/ | jq '.'