#!/bin/bash
curl -sH 'X-IOTA-API-VERSION: 1.4' -d '{"command":"getNodeInfo"}' http://localhost:14266/ | jq '.'
