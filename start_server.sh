#!/bin/bash

# Change to the application directory
cd "$(dirname "$0")"

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "Bundler is not installed. Installing..."
    gem install bundler
fi

# Install dependencies if needed
if [ ! -d "vendor/bundle" ]; then
    echo "Installing dependencies..."
    bundle config set --local path 'vendor/bundle'
    bundle install
fi

# Start the server
echo "Starting server on port 3000..."
bundle exec rackup -p 3000 -s puma
