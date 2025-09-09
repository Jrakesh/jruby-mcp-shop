# -*- encoding: utf-8 -*-
# stub: fast-mcp 1.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "fast-mcp".freeze
  s.version = "1.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/yjacquin/fast_mcp/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/yjacquin/fast_mcp", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/yjacquin/fast_mcp" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yorick Jacquin".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-06-01"
  s.description = "A flexible and powerful implementation of the MCP with multiple approaches for defining tools.".freeze
  s.email = ["yorickjacquin@gmail.com".freeze]
  s.homepage = "https://github.com/yjacquin/fast_mcp".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.3.3".freeze
  s.summary = "A Ruby implementation of the Model Context Protocol.".freeze

  s.installed_by_version = "3.3.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.8"])
    s.add_runtime_dependency(%q<base64>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<dry-schema>.freeze, ["~> 1.14"])
    s.add_runtime_dependency(%q<json>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<mime-types>.freeze, ["~> 3.4"])
    s.add_runtime_dependency(%q<rack>.freeze, ["~> 3.1"])
  else
    s.add_dependency(%q<addressable>.freeze, ["~> 2.8"])
    s.add_dependency(%q<base64>.freeze, [">= 0"])
    s.add_dependency(%q<dry-schema>.freeze, ["~> 1.14"])
    s.add_dependency(%q<json>.freeze, ["~> 2.0"])
    s.add_dependency(%q<mime-types>.freeze, ["~> 3.4"])
    s.add_dependency(%q<rack>.freeze, ["~> 3.1"])
  end
end
