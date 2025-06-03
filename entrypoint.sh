#!/bin/bash
set -e

# Start corkboard in the background
/fuiz/corkboard/corkboard &

# Start hosted-server in the background
/fuiz/backend/fuiz-server &

# Start the website
cd /fuiz/frontend
wrangler dev --compatibility-flags=nodejs_compat --port 3000 --local-protocol=http --host=0.0.0.0

# Wait for all background processes
wait