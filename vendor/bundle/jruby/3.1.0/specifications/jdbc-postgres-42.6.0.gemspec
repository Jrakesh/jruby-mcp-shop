# -*- encoding: utf-8 -*-
# stub: jdbc-postgres 42.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jdbc-postgres".freeze
  s.version = "42.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nick Sieger, Ola Bini, Karol Bucek and JRuby contributors".freeze]
  s.date = "2023-06-10"
  s.description = "Install this gem `require 'jdbc/postgres'` and invoke `Jdbc::Postgres.load_driver` within JRuby to load the driver.".freeze
  s.email = ["nick@nicksieger.com".freeze, "ola.bini@gmail.com".freeze, "self@kares.org".freeze]
  s.homepage = "http://github.com/jruby/activerecord-jdbc-adapter/tree/master/jdbc-postgres".freeze
  s.licenses = ["BSD".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.3.3".freeze
  s.summary = "JDBC driver for JRuby and PostgreSQL (used by ActiveRecord-JDBC).".freeze

  s.installed_by_version = "3.3.3" if s.respond_to? :installed_by_version
end
