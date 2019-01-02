require 'yaml'
require 'sequel'

DB = Sequel.connect(ENV["DB_URI"])
DATA_DIR = File.join(__dir__, "..", "data")

models_dir = File.join(__dir__, "..", "models")

Dir.glob("#{models_dir}/*.rb").each { |model| require_relative model }

[
  [Exile, 'exiles'],
  [InputMethod, 'input_methods'],
  [Stage, 'stages'],
  [Triumvirate, 'triumvirates'],
].each do |klass, table|
  klass.dataset = DB[table.intern]
  instances = YAML.load(File.read(File.join(DATA_DIR, table+".yaml")))
  instances.each { |instance|
    begin
      klass.create(instance)
      $stderr.puts("(#{table}) INSERT #{instance[:name]}")
    rescue Sequel::UniqueConstraintViolation
      # skip
    end
  }
end

# Also insert a bunch of fake users for development purposes.
if ENV["RACK_ENV"] == "development"
  User.dataset = DB[:users]

  fake_users = YAML.load(File.read(File.join(DATA_DIR, "fake_users.yaml")))

  fake_users.each do |user|
    user.merge!({
      :member_since => Time.now,
    })

    u = User.new(user)

    begin
      u.save
      $stderr.puts("(users) INSERT FAKE USER #{u.username}")
    rescue Sequel::UniqueConstraintViolation
      # skip
    end
  end
end
