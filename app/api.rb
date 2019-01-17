class RiteClubWeb
  post '/api/v1/rites/?' do
    out_obj = {
      :player_a_id => params['player_a.id'].to_i,
      :player_b_id => params['player_b.id'].to_i,
      :player_a_triumvirate_team_index => params['player_a.triumvirate'].to_i,
      :player_b_triumvirate_team_index => params['player_b.triumvirate'].to_i,
      :player_a_input_method_id => params['player_a.input_method'].to_i,
      :player_b_input_method_id => params['player_b.input_method'].to_i,
      :stage_match_site => params['rite.stage'].to_i,
      :talismans_enabled => params['rite.talismans_enabled'].downcase == "true",
      :masteries_allowed => params['rite.masteries_allowed'].to_i,
      :player_a_pyre_start_health => params['player_a.pyre_start_health'].to_i,
      :player_b_pyre_start_health => params['player_b.pyre_start_health'].to_i,
      :player_a_pyre_end_health => params['player_a.pyre_end_health'].to_i,
      :player_b_pyre_end_health => params['player_b.pyre_end_health'].to_i,
      :timestamp => Time.now, # XXX should be when the rite started
      :hosting_player_id => params['player_a.host'].downcase == "true" ? params['player_a.id'].to_i : params['player_b.id'].to_i,
      :duration => params['rite.duration'].to_i,
      :player_a_exile_1_character_index => params['player_a.exiles.0.character_index'].to_i,
      :player_a_exile_2_character_index => params['player_a.exiles.1.character_index'].to_i,
      :player_a_exile_3_character_index => params['player_a.exiles.2.character_index'].to_i,
      :player_b_exile_1_character_index => params['player_b.exiles.0.character_index'].to_i,
      :player_b_exile_2_character_index => params['player_b.exiles.1.character_index'].to_i,
      :player_b_exile_3_character_index => params['player_b.exiles.2.character_index'].to_i,
      :label => params['rite.label'],
    }

    rite = Rite.new(out_obj)

    if not rite.valid?
      # XXX 400
    end

    rite.save
    status 201 # XXX Created
  end

  # Returns a collection of usernames and their user IDs. This endpoin tis
  # intended to be used by the Rite Club Companion to populate a list of
  # available players to compete against.
  #
  # XXX in theory we could also provide little avatars next to their names,
  # too.
  get '/api/v1/usernames/?' do
    json_response!

    obj = User.all.map { |user|
      {
        :id => user.id,
        :username => user.username,
      }
    }

    return render_json_response(obj)
  end

  get '/api/v1/:table/:id/?' do
    json_response!
    table = params[:table].intern
    id = params[:id].to_i
    return json_not_found if !DB.tables.include?(table)
    obj = DB[table].where(:id => id).to_a.first
    if obj
      return render_json_response(obj)
    else
      not_found
    end
  end
end
