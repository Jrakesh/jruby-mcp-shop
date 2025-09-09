#!/bin/bash

# Change to the application directory
cd "$(dirname "$0")"

# Find and kill the existing server process
echo "Stopping existing server..."
pkill -f "puma.*-p 3000"

# Wait a moment for the process to stop
sleep 2

# Start the server again using start_server.sh
echo "Restarting server..."
./start_server.sh
