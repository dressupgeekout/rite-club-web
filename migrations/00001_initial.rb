require 'sequel'

DEFAULT_PARSEC_HOST = false
DEFAULT_RITE_LABEL = "casual".freeze

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, text: true, unique: true, null: false
      String :realname, text: true, unique: false, null: true
      DateTime :member_since, null: false
      String :location, text: true, unique: false, null: true
      String :email, text: true, unique: true, null: false
      String :passwd, text: true, null: false
      String :salt, text: true, null: false
      TrueClass :parsec_host, default: DEFAULT_PARSEC_HOST
      String :biography, text: true, unique: false, null: true
    end

    create_table(:triumvirates) do
      primary_key :id
      Integer :team_index, unique: true, null: false
      String :name, text: true, unique: true, null: false
    end

    create_table(:stages) do
      primary_key :id
      String :name, text: true, unique: true, null: false

      # The numeric equivalent of "MatchSiteA", "MatchSiteB", etc.
      Integer :match_site, unique: true, null: false
    end

    create_table(:exiles) do
      primary_key :id
      Integer :character_index, unique: true, null: false
      String :name, text: true, unique: true, null: false
      String :portrait_url, text: true
    end

    create_table(:input_methods) do
      primary_key :id
      String :name, text: true, unique: true, null: false
    end

    create_table(:talismans) do
      primary_key :id
      String :name, text: true, unique: true, null: false
    end

    create_table(:rites) do
      primary_key :id
      foreign_key :player_a_id, :users
      foreign_key :player_b_id, :users
      foreign_key :player_a_triumvirate_team_index, :triumvirates, key: :team_index
      foreign_key :player_b_triumvirate_team_index, :triumvirates, key: :team_index
      foreign_key :player_a_input_method_id, :input_methods
      foreign_key :player_b_input_method_id, :input_methods
      foreign_key :stage_match_site, :stages, key: :match_site
      TrueClass :talismans_enabled
      Integer :masteries_allowed
      Integer :player_a_pyre_start_health
      Integer :player_b_pyre_start_health
      Integer :player_a_pyre_end_health
      Integer :player_b_pyre_end_health
      Integer :timestamp # in Unix time
      foreign_key :hosting_player_id, :users
      Integer :duration # in seconds
      foreign_key :player_a_exile_1_character_index, :exiles, key: :character_index
      foreign_key :player_a_exile_2_character_index, :exiles, key: :character_index
      foreign_key :player_a_exile_3_character_index, :exiles, key: :character_index
      foreign_key :player_b_exile_1_character_index, :exiles, key: :character_index
      foreign_key :player_b_exile_2_character_index, :exiles, key: :character_index
      foreign_key :player_b_exile_3_character_index, :exiles, key: :character_index
      String :label, text: true, unique: false, null: true, default: DEFAULT_RITE_LABEL
    end
  end
end
