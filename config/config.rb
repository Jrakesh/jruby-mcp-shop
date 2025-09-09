require 'yaml'
require 'erb'

module Config
  class << self
    def load
      @config ||= begin
        file_path = File.join(File.dirname(__FILE__), 'config.yml')
        yaml = ERB.new(File.read(file_path)).result
        YAML.load(yaml)[ENV['RACK_ENV'] || 'development']
      end
    end

    def method_missing(name)
      load[name.to_s]
    end
  end
end
