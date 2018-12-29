class Match < Sequel::Model
  plugin :validation_helpers

  def validate
    super
  end
end
