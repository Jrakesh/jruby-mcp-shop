class DebugLogger
  def self.log(method_name, data)
    puts "\n[DEBUG] #{method_name} returned:"
    puts JSON.pretty_generate(data)
    puts "\n"
  rescue => e
    puts "[DEBUG] #{method_name} error logging: #{e.message}"
  end
end
