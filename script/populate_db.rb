require 'yaml'
require 'sequel'

DB = Sequel.connect(ENV["DB_URI"])
DATA_DIR = File.join(__dir__, "..", "data")

models_dir = File.join(__dir__, "..", "models")

Dir.glob("#{models_dir}/*.rb").each { |model| require_relative model }

[
  [Exile, 'exiles', 'exile_'],
  [InputMethod, 'input_methods', 'input_method_'],
  [Stage, 'stages', 'stage_'],
  [Triumvirate, 'triumvirates', 'triumvirate_'],
].each do |klass, table, column_prefix|
  klass.dataset = DB[table.intern]
  instances = YAML.load(File.read(File.join(DATA_DIR, table+".yaml")))
  instances.each { |instance|
    x = klass.new({"#{column_prefix}name".intern => instance})

    begin
      x.save
      $stderr.puts("(#{table}) INSERT #{instance}")
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
      :user_member_since => Time.now,
    })

    u = User.new(user)

    begin
      u.save
      $stderr.puts("(users) INSERT FAKE USER #{u.user_username}")
    rescue Sequel::UniqueConstraintViolation
      # skip
    end
  end

  Rite.dataset = DB[:rites]
  example_rite = YAML.load(File.read(File.join(DATA_DIR, "example_rite.yaml")))

  example_rite.merge!({
    :rite_timestamp => Time.now,
  })

  r = Rite.new(example_rite)
  r.save
end
