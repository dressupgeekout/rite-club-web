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
    return "#{ENV['S3_BUCKET_URL']}/img/exiles/#{self.safe_name}.png"
  end

  def portrait_img_small
    return "#{ENV['S3_BUCKET_URL']}/img/exiles/#{self.safe_name}-small.png"
  end

  # Returns the name of the exile, but without any weird characters unsafe for
  # filenames. Apostrophes and spaces are simply stripped, and all
  # characters are sent lowercase.
  def safe_name
    return self.name.downcase.gsub("'", "").gsub(" ", "")
  end
end
