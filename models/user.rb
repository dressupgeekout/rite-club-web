require 'sequel'

class User < Sequel::Model
  plugin :validation_helpers

  def validate
    super
  end
end
