require 'sequel'

DEFAULT_MASTERIES_ALLOWED = 4
DEFAULT_PYRE_HEALTH = 100
DEFAULT_TALISMANS_ENABLED = true
DEFAULT_PARSEC_HOST = false

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :user_username, text: true, unique: true, null: false
      String :user_realname, text: true, unique: false, null: true
      DateTime :user_member_since, null: false
      String :user_location, text: true, unique: false, null: true
      String :user_email, text: true, unique: true, null: false
      String :user_passwd, text: true, null: false
      String :user_salt, text: true, null: false
      TrueClass :user_parsec_host, default: DEFAULT_PARSEC_HOST
    end

    create_table(:triumvirates) do
      primary_key :id
      String :triumvirate_name, text: true, unique: true, null: false
    end

    create_table(:stages) do
      primary_key :id
      String :stage_name, text: true, unique: true, null: false
    end

    create_table(:exiles) do
      primary_key :id
      String :exile_name, text: true, unique: true, null: false
      String :exile_portrait_url, text: true
    end

    create_table(:input_methods) do
      primary_key :id
      String :input_method_name, text: true, unique: true, null: false
    end

    create_table(:talismans) do
      primary_key :id
      String :talisman_name, text: true, unique: true, null: false
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
      TrueClass :rite_talismans_enabled, default: DEFAULT_TALISMANS_ENABLED
      Integer :rite_masteries_allowed, default: DEFAULT_MASTERIES_ALLOWED
      Integer :rite_player_a_pyre_health, default: DEFAULT_PYRE_HEALTH
      Integer :rite_player_b_pyre_health, default: DEFAULT_PYRE_HEALTH
      DateTime :rite_timestamp
      foreign_key :rite_hosting_player_id, :users
      Integer :rite_duration # in seconds
      foreign_key :player_a_exile_1_id, :exiles
      foreign_key :player_a_exile_2_id, :exiles
      foreign_key :player_a_exile_3_id, :exiles
      foreign_key :player_b_exile_1_id, :exiles
      foreign_key :player_b_exile_2_id, :exiles
      foreign_key :player_b_exile_3_id, :exiles
    end

    create_table(:matches) do
      primary_key :id
    end
  end
end
