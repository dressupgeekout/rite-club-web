require 'sequel'
require 'yaml'

class InputMethod < Sequel::Model
  plugin :validation_helpers

  VALID_INPUT_METHOD_NAMES = YAML.load(File.read(File.join(__dir__, "..", "data", "input_methods.yaml")))

  def validate
    super
    validates_includes VALID_INPUT_METHOD_NAMES, :input_method_name
  end
end
