require 'sequel'

DEFAULT_MASTERIES_ALLOWED = 4
DEFAULT_PYRE_HEALTH = 100
DEFAULT_TALISMANS_ENABLED = true
DEFAULT_PARSEC_HOST = false

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
    end

    create_table(:triumvirates) do
      primary_key :id
      String :name, text: true, unique: true, null: false
    end

    create_table(:stages) do
      primary_key :id
      String :name, text: true, unique: true, null: false
    end

    create_table(:exiles) do
      primary_key :id
      String :name, text: true, unique: true, null: false
      String :portrait_url, text: true
      Integer :character_index, unique: true, null: false
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
      foreign_key :player_a_triumvirate_id, :triumvirates
      foreign_key :player_b_triumvirate_id, :triumvirates
      foreign_key :player_a_input_method_id, :input_methods
      foreign_key :player_b_input_method_id, :input_methods
      foreign_key :stage_id, :stages
      TrueClass :talismans_enabled, default: DEFAULT_TALISMANS_ENABLED
      Integer :masteries_allowed, default: DEFAULT_MASTERIES_ALLOWED
      Integer :player_a_pyre_health, default: DEFAULT_PYRE_HEALTH
      Integer :player_b_pyre_health, default: DEFAULT_PYRE_HEALTH
      DateTime :timestamp
      foreign_key :hosting_player_id, :users
      Integer :duration # in seconds
      foreign_key :player_a_exile_1_character_index, :exiles, key: :character_index
      foreign_key :player_a_exile_2_character_index, :exiles, key: :character_index
      foreign_key :player_a_exile_3_character_index, :exiles, key: :character_index
      foreign_key :player_b_exile_1_character_index, :exiles, key: :character_index
      foreign_key :player_b_exile_2_character_index, :exiles, key: :character_index
      foreign_key :player_b_exile_3_character_index, :exiles, key: :character_index
    end

    create_table(:matches) do
      primary_key :id
    end
  end
end
