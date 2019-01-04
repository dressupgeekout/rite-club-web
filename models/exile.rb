require 'sequel'
require 'yaml'

class Exile < Sequel::Model
  plugin :validation_helpers

  VALID_EXILE_NAMES =
    YAML.load(File.read(File.join(__dir__, "..", "data", "exiles.yaml"))).
    map { |exile| exile[:name] }

  def validate
    super
    validates_includes VALID_EXILE_NAMES, :name
  end

  def portrait_img
  end

  def portrait_img_small
    # XXX TODO
  end

  # Returns the name of the exile, but without any weird characters unsafe for
  # filenames.
  def safe_name
    return self.name.gsub("'", "").gsub(" ", "")
  end
end
