#!/bin/bash
NEIGHBOUR=$1
curl -sH 'X-IOTA-API-VERSION: 1.4' -d '{"command":"addNeighbors", "uris":["'$NEIGHBOUR'"]}' http://127.0.0.1:14264/ | jq '.'