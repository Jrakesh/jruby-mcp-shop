# -*- encoding: utf-8 -*-
# stub: sequel_secure_password 0.2.15 ruby lib

Gem::Specification.new do |s|
  s.name = "sequel_secure_password".freeze
  s.version = "0.2.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mateusz Lenik".freeze]
  s.date = "2017-10-11"
  s.description = "Plugin adds authentication methods to Sequel models using BCrypt library.".freeze
  s.email = ["mlen@mlen.pl".freeze]
  s.homepage = "http://github.com/mlen/sequel_secure_password".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.3".freeze
  s.summary = "Plugin adds BCrypt authentication and password hashing to Sequel models. Model using this plugin should have 'password_digest' field.  This plugin was created by extracting has_secure_password strategy from rails.".freeze

  s.installed_by_version = "3.3.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<bcrypt>.freeze, [">= 3.1", "< 4.0"])
    s.add_runtime_dependency(%q<sequel>.freeze, [">= 4.1.0", "< 6.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12"])
    s.add_development_dependency(%q<rubygems-tasks>.freeze, ["~> 0.2"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3", ">= 1.3.0"])
  else
    s.add_dependency(%q<bcrypt>.freeze, [">= 3.1", "< 4.0"])
    s.add_dependency(%q<sequel>.freeze, [">= 4.1.0", "< 6.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12"])
    s.add_dependency(%q<rubygems-tasks>.freeze, ["~> 0.2"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3", ">= 1.3.0"])
  end
end
