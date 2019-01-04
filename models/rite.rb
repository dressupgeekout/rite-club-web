require 'sequel'

class Rite < Sequel::Model
  plugin :validation_helpers

  def validate
    super

    if self.player_a_id == self.player_b_id
      errors.add(:player_a_id, "Player A cannot be the same as Player B")
      errors.add(:player_b_id, "Player B cannot be the same as Player A")
    end

    validates_operator :>, 0, :duration
    validates_operator :<=, 4, :masteries_allowed

    if self.player_a_pyre_end_health <= 0 && self.player_b_pyre_end_health <= 0
      errors.add("Both players lost the rite?!?")
    end
  end
end
