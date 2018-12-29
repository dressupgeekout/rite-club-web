require 'sequel'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, text: true, unique: true, null: false
      String :realname, text: true, unique: false, null: true
      DateTime :member_since, null: false
      String :location, text: true, unique: false, null: true
    end

    create_table(:triumvirates) do
      primary_key :id
      String :name, text: true, unique: true, null: false
    end

    create_table(:landmarks) do
      primary_key :id
      String :name, text: true, unique: true, null: false
    end

    create_table(:exiles) do
      primary_key :id
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

    create_table(:matches) do
      primary_key :id
      String :player_a_username, text: true, null: false
      String :player_b_username, text: true, null: false
      Integer :player_a_triumvirate_id, null: false
      Integer :player_b_triumvirate_id, null: false
      Integer :player_a_input_method_id, null: false
      Integer :player_b_input_method_id, null: false
      Integer :landmark_id, null: false
      TrueClass :talismans_enabled 
      Integer :masteries_allowed
      Integery :pyre_health
    end
  end
end
