require 'sequel'
require 'yaml'

class Triumvirate < Sequel::Model
  plugin :validation_helpers

  VALID_TRIUMVIRATE_NAMES = YAML.load(File.read(File.join(__dir__, "..", "data", "triumvirates.yaml")))

  def validate
    super
    validates_includes VALID_TRIUMVIRATE_NAMES, :triumvirate_name
  end
end
