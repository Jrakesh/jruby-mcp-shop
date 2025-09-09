#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt for PostgreSQL credentials
get_postgres_credentials() {
    read -p "PostgreSQL username (default: postgres): " DB_USER
    DB_USER=${DB_USER:-postgres}
    
    read -s -p "PostgreSQL password: " DB_PASSWORD
    echo
    
    export DB_USER
    export DB_PASSWORD
}

# Check for required software
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check for JRuby
    if ! command_exists jruby; then
        print_error "JRuby is not installed. Please install JRuby first."
        exit 1
    fi
    
    # Check for PostgreSQL
    if ! command_exists psql; then
        print_error "PostgreSQL is not installed. Please install PostgreSQL first."
        exit 1
    fi
    
    # Check if PostgreSQL server is running
    if ! pg_isready >/dev/null 2>&1; then
        print_error "PostgreSQL server is not running. Please start PostgreSQL first."
        exit 1
    fi
    
    print_status "All prerequisites met!"
}

# Install required gems
install_dependencies() {
    print_status "Installing required gems..."
    
    # Install bundler if not already installed
    if ! command_exists bundle; then
        print_status "Installing bundler..."
        jruby -S gem install bundler
    fi
    
    # Install project dependencies
    JRUBY_OPTS="--dev" jruby -S bundle install
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install dependencies"
        exit 1
    fi
    
    print_status "Dependencies installed successfully!"
}

# Set up the database
setup_database() {
    print_status "Setting up database..."
    
    # Export database configuration
    export DATABASE_URL="jdbc:postgresql://localhost/ecommerce_db"
    
    # Drop existing database if it exists
    PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -c "DROP DATABASE IF EXISTS ecommerce_db;" postgres
    
    if [ $? -ne 0 ]; then
        print_error "Failed to drop existing database"
        exit 1
    fi
    
    # Create new database
    PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -c "CREATE DATABASE ecommerce_db;" postgres
    
    if [ $? -ne 0 ]; then
        print_error "Failed to create database"
        exit 1
    fi
    
    # Grant privileges
    PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -c "GRANT ALL PRIVILEGES ON DATABASE ecommerce_db TO $DB_USER;" postgres
    
    print_status "Database created successfully!"
}

# Run database migrations
run_migrations() {
    print_status "Running database migrations..."
    
    JRUBY_OPTS="--dev" jruby -S rake db:migrate
    
    if [ $? -ne 0 ]; then
        print_error "Failed to run migrations"
        exit 1
    fi
    
    print_status "Migrations completed successfully!"
}

# Seed the database
seed_database() {
    print_status "Seeding the database..."
    
    JRUBY_OPTS="--dev" jruby -S rake db:seed
    
    if [ $? -ne 0 ]; then
        print_error "Failed to seed database"
        exit 1
    fi
    
    print_status "Database seeded successfully!"
}

# Main setup process
main() {
    print_status "Starting setup process..."
    
    # Check prerequisites
    check_prerequisites
    
    # Get PostgreSQL credentials
    get_postgres_credentials
    
    # Install dependencies
    install_dependencies
    
    # Set up database
    setup_database
    
    # Run migrations
    run_migrations
    
    # Seed database
    seed_database
    
    print_status "Setup completed successfully!"
    print_status "You can now start the application with: JRUBY_OPTS=\"--dev\" jruby -S rackup"
}

# Run main function
main
