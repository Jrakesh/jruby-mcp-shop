require 'sequel'

Sequel::Model.plugin :json_serializer
Sequel::Model.db = DB if defined?(DB)
