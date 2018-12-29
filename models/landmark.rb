require 'sequel'
require 'yaml'

class Landmark < Sequel::Model
  plugin :validation_helpers

  VALID_LANDMARK_NAMES = YAML.load(File.read(File.join(__dir__, "..", "data", "landmarks.yaml")))

  def validate
    super
    validates_includes VALID_LANDMARK_NAMES, :landmark_name
  end
end
