require 'sequel'
require 'yaml'

class Triumvirate < Sequel::Model
  plugin :validation_helpers

  VALID_TRIUMVIRATE_NAMES = 
    YAML.load(File.read(File.join(__dir__, "..", "data", "triumvirates.yaml"))).
    map { |triumvirate| triumvirate[:name] }

  def validate
    super
    validates_includes VALID_TRIUMVIRATE_NAMES, :name
  end

  def sigil_img
    return "/img/triumvirates/#{self.safe_name}.png"
  end

  def sigil_img_small
    return "/img/triumvirates/#{self.safe_name}-small.png"
  end

  def sigil_img_medium
    return "/img/triumvirates/#{self.safe_name}-medium.png"
  end

  # Returns the name of the triumvirate, but without any weird characters
  # unsafe for filenames. Apostrophes and spaces are simply stripped, and
  # all characters are sent lowercase.
  def safe_name
    return self.name.downcase.gsub("'", "").gsub(" ", "")
  end
end
