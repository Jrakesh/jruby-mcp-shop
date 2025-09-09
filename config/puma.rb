#!/usr/bin/env puma

# The directory to operate out of.
directory File.expand_path('..', __dir__)

# Use an object or block as the rack application.
app do |env|
  require_relative '../config.ru'
  run Rack::Builder.new { eval(File.read('../config.ru')) }
end

# Set the environment in which the rack's app will run.
environment ENV.fetch('RACK_ENV') { 'development' }

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
threads 0, 16

# Use the `port` option to listen on a specific port.
port ENV.fetch('PORT') { 3000 }

# Daemonize the server into the background.
# daemonize true if ENV['RACK_ENV'] == 'production'

# Store the pid of the server in a file, for use with the 'stop' command.
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/puma.pid' }

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
