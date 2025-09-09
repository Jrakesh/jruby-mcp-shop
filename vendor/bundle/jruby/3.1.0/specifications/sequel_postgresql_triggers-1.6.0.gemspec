# -*- encoding: utf-8 -*-
# stub: sequel_postgresql_triggers 1.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sequel_postgresql_triggers".freeze
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jeremy Evans".freeze]
  s.date = "2024-01-18"
  s.email = "code@jeremyevans.net".freeze
  s.homepage = "https://github.com/jeremyevans/sequel_postgresql_triggers".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--inline-source".freeze, "--line-numbers".freeze, "--title".freeze, "Sequel PostgreSQL Triggers: Database enforced timestamps, immutable columns, and counter/sum caches".freeze, "README.rdoc".freeze, "MIT-LICENSE".freeze, "lib".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "3.3.3".freeze
  s.summary = "Database enforced timestamps, immutable columns, counter/sum caches, and touch propogation".freeze

  s.installed_by_version = "3.3.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<sequel>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, [">= 5"])
    s.add_development_dependency(%q<minitest-global_expectations>.freeze, [">= 0"])
  else
    s.add_dependency(%q<sequel>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 5"])
    s.add_dependency(%q<minitest-global_expectations>.freeze, [">= 0"])
  end
end
