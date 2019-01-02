class RiteClubWeb
  post '/api/v1/rites/?' do
    json_response!

    obj = JSON.load(request.body.read)

    playera = obj['player_a']
    playerb = obj['player_b']
    rite = obj['rite']

    out_obj = {
      :player_a_id => playera['id'],
      :player_b_id => playerb['id'],
      :player_a_triumvirate_id => playera['triumvirate'],
      :player_b_triumvirate_id => playerb['triumvirate'],
      :player_a_input_method_id => playera['input_method'],
      :player_b_input_method_id => playera['input_method'],
      :stage_id => rite['stage'],
      :talismans_enabled => rite['talismans_enabled'],
      :masteries_allowed => rite['masteries_allowed'],
      :player_a_pyre_health => playera['pyre_health'],
      :player_b_pyre_health => playerb['pyre_health'],
      :timestamp => Time.now, # XXX should be when the rite started
      :hosting_player_id => playera['host'] ? playera['id'] : playerb['id'],
      :duration => rite['duration'],
      :player_a_exile_1_character_index => playera['exiles'][0]['character_index'],
      :player_a_exile_2_character_index => playera['exiles'][1]['character_index'],
      :player_a_exile_3_character_index => playera['exiles'][2]['character_index'],
      :player_b_exile_1_character_index => playerb['exiles'][0]['character_index'],
      :player_b_exile_2_character_index => playerb['exiles'][1]['character_index'],
      :player_b_exile_3_character_index => playerb['exiles'][2]['character_index'],
    }

    rite = Rite.new(out_obj)

    if not rite.valid?
      # XXX 400
    end

    rite.save
    status 201 # XXX Created
    # XXX json_obj out
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
