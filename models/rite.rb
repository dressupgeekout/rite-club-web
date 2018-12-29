require 'sequel'

class Rite < Sequel::Model
  plugin :validation_helpers

  def validate
    self
  end
end
