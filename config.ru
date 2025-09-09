require 'bundler'
Bundler.require
require 'securerandom'

# Set environment
ENV['RACK_ENV'] ||= 'development'

require './lib/ecommerce_mcp'
require './app'

# Set up session middleware with secure key
session_secret = ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
use Rack::Session::Cookie,
  key: 'rack.session',
  secret: session_secret,
  same_site: :lax,
  secure: true

# Initialize MCP instance
mcp = EcommerceMCP.new(DB)

# Run the Sinatra application
run Sinatra::Application
