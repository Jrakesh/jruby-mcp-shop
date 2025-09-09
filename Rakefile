require 'rake'
require 'sequel'
require 'yaml'
require 'erb'

# Load database configuration
def load_config
  config_file = File.read(File.join(File.dirname(__FILE__), 'config', 'config.yml'))
  YAML.load(ERB.new(config_file).result)
end

# Get database configuration for current environment
def db_config
  @env ||= ENV['RACK_ENV'] || 'development'
  @config ||= load_config[@env]
end

# Set up database connection
DB = Sequel.connect(
  db_config['database_url'],
  user: db_config['database_user'],
  password: db_config['database_password']
)

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel::Migrator.run(DB, "db/migrations", target: version)
    puts "Migrations completed successfully"
  end

  desc "Rollback the last migration"
  task :rollback do
    Sequel.extension :migration
    database = EcommerceApp::DB
    current_version = database[:schema_migrations].order(:filename).last[:filename].to_i
    target_version = current_version - 1
    Sequel::Migrator.run(database, "db/migrations", target: target_version)
    puts "Rolled back to version #{target_version}"
  end

  desc "Create the database"
  task :create do
    config = {
      adapter: 'jdbc',
      uri: 'jdbc:postgresql://localhost/postgres',
      user: ENV['DB_USER'] || 'postgres',
      password: ENV['DB_PASSWORD'] || 'postgres'
    }
    
    admin_db = Sequel.connect(config)
    begin
      admin_db.execute "CREATE DATABASE ecommerce_db;"
      puts "Database created successfully"
    rescue Sequel::DatabaseError => e
      puts "Database already exists"
    ensure
      admin_db.disconnect
    end
  end

  desc "Drop the database"
  task :drop do
    config = {
      adapter: 'jdbc',
      uri: 'jdbc:postgresql://localhost/postgres',
      user: ENV['DB_USER'] || 'postgres',
      password: ENV['DB_PASSWORD'] || 'postgres'
    }
    
    admin_db = Sequel.connect(config)
    begin
      admin_db.execute "DROP DATABASE IF EXISTS ecommerce_db;"
      puts "Database dropped successfully"
    ensure
      admin_db.disconnect
    end
  end

  desc "Reset the database"
  task reset: [:drop, :create, :migrate]

  desc "Seed the database with sample data"
  task :seed => :environment do
    require_relative 'db/seeds'
    puts "Database seeded successfully"
  end
  
  task :environment do
    require 'sequel'
    require 'yaml'
    require 'erb'
    
    config = YAML.load(ERB.new(File.read('config/config.yml')).result)
    env = ENV['RACK_ENV'] || 'development'
    db_config = config[env]
    
    Sequel::Model.db = Sequel.connect(
      db_config['database_url'],
      user: db_config['database_user'],
      password: db_config['database_password']
    )
  end

  desc "Show current schema version"
  task :version do
    version = if EcommerceApp::DB.tables.include?(:schema_migrations)
      EcommerceApp::DB[:schema_migrations].order(:filename).last[:filename]
    else
      'Not migrated yet'
    end
    puts "Current schema version: #{version}"
  end
end

desc "Start the application"
task :start do
  ruby "app.rb"
end

desc "Start the application in development mode"
task :dev do
  system "bundle exec rerun --force-polling -- rackup -p 4567"
end

# Set default task
task default: 'db:migrate'
