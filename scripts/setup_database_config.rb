#!/usr/bin/env jruby

require 'yaml'
require 'fileutils'

# Default configuration
config = {
  'development' => {
    'adapter' => 'jdbc',
    'uri' => 'jdbc:postgresql://localhost/ecommerce_db',
    'username' => ENV['DB_USER'] || 'postgres',
    'password' => ENV['DB_PASSWORD'] || 'postgres',
    'host' => 'localhost',
    'pool' => 5
  },
  'test' => {
    'adapter' => 'jdbc',
    'uri' => 'jdbc:postgresql://localhost/ecommerce_test_db',
    'username' => ENV['DB_USER'] || 'postgres',
    'password' => ENV['DB_PASSWORD'] || 'postgres',
    'host' => 'localhost',
    'pool' => 5
  },
  'production' => {
    'adapter' => 'jdbc',
    'uri' => ENV['DATABASE_URL'],
    'username' => ENV['DB_USER'],
    'password' => ENV['DB_PASSWORD'],
    'host' => ENV['DB_HOST'] || 'localhost',
    'pool' => ENV['DB_POOL'] || 10
  }
}

# Create config directory if it doesn't exist
FileUtils.mkdir_p('config')

# Write configuration to file
File.write('config/database.yml', config.to_yaml)

puts "Database configuration file created at config/database.yml"
