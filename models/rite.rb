require 'sequel'

require_relative 'exile'
require_relative 'triumvirate'

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
      errors.add(:player_a_pyre_end_health, "Both players lost the rite?!?")
      errors.add(:player_b_pyre_end_health, "Both players lost the rite?!?")
    end
  end

  def url
    return "/rites/#{self.id}"
  end

  # Returns `:player_a` or `:player_b`.
  def winner
    return self.player_a_pyre_end_health <= 0 ? :player_b : :player_a
  end

  # Returns `:player_a` or `:player_b`.
  def loser
    return winner == :player_a ? :player_b : :player_a
  end

  # Returns an array.
  def cheer_sounds
    exile_indexes = []

    (1..3).each do |n|
      exile_indexes << self.send("#{self.winner}_exile_#{n}_character_index".intern)
    end

    triumvirate_index = self.send("#{self.winner}_triumvirate_team_index".intern)

    exiles = exile_indexes.map { |index| Exile.where(:character_index => index).first }
    triumvirate = Triumvirate.where(:team_index => triumvirate_index).first

    return exiles.map { |exile|
      "/audio/cheers/cheer_#{exile.safe_name}_#{triumvirate.safe_name}.ogg"
    }
  end

  def pretty_duration
    sec = self.duration.dup
    m = sec / 60
    sec -= (m*60)
    return sprintf("%d:%02d", m, sec)
  end
end
