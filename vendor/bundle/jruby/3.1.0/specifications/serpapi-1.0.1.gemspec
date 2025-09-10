# -*- encoding: utf-8 -*-
# stub: serpapi 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "serpapi".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["victor benarbia".freeze, "Julien Khaleghy".freeze]
  s.date = "1980-01-02"
  s.description = "Integrate powerful search functionality into your Ruby application with SerpApi. SerpApi offers official \nsupport for Google, Google Maps, Google Shopping, Baidu, Yandex, Yahoo, eBay, App Stores, and more. \nAccess a vast range of data, including web search results, local business listings, and product \ninformation.".freeze
  s.email = "victor@serpapi.com".freeze
  s.homepage = "https://github.com/serpapi/serpapi-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.3.3".freeze
  s.summary = "Official Ruby library for SerpApi.com".freeze

  s.installed_by_version = "3.3.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<http>.freeze, ["~> 5.2"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.2.1"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.11"])
    s.add_development_dependency(%q<yard>.freeze, ["~> 0.9.28"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.75.7"])
    s.add_development_dependency(%q<csv>.freeze, [">= 0"])
  else
    s.add_dependency(%q<http>.freeze, ["~> 5.2"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.2.1"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.11"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9.28"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 1.75.7"])
    s.add_dependency(%q<csv>.freeze, [">= 0"])
  end
end
