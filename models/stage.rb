require 'sequel'
require 'yaml'

class Stage < Sequel::Model
  plugin :validation_helpers

  VALID_NAMES = 
    YAML.load(File.read(File.join(__dir__, "..", "data", "stages.yaml"))).
    map { |stage| stage[:name] }

  def validate
    super
    validates_includes VALID_NAMES, :name
  end
end
