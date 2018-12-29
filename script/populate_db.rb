require 'yaml'
require 'sequel'

DB = Sequel.connect(ENV["DB_URI"])

models_dir = File.join(__dir__, "..", "models")

Dir.glob("#{models_dir}/*.rb").each { |model| require_relative model }

[
  [Exile, 'exiles'],
  [InputMethod, 'input_methods'],
  [Triumvirate, 'triumvirates'],
].each do |klass, table|
  klass.dataset = DB[table.intern]
  instances = YAML.load(File.read(File.join(__dir__, "..", "data", table+".yaml")))
  instances.each { |instance|
    x = klass.new(name: instance)

    begin
      x.save
      $stderr.puts("(#{table}) INSERT #{instance}")
    rescue Sequel::UniqueConstraintViolation
      # skip
    end
  }
end
