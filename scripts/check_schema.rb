require 'sequel'
require_relative '../config/config'

db = Sequel.connect(Config.database_url)
puts "Orders table columns:"
puts db.schema(:orders).map { |col| col[0] }.join(", ")
