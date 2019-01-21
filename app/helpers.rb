class RiteClubWeb
  JSON_CONTENT_TYPE = "application/json;charset=utf-8"

  helpers do
    def h(str)
      return Rack::Utils.escape_html(str)
    end

    def json_response!
      response["Content-Type"] = JSON_CONTENT_TYPE
    end

    def json_response?
      return response["Content-Type"] == JSON_CONTENT_TYPE
    end

    def render_json_response(obj)
      response.write(JSON.dump(obj) + "\n")
      return response
    end

    def static_get_all(klass)
      key = "all_#{klass.table_name}"
      begin
        result = $cache.get(key)
      rescue Memcached::NotFound
        result = klass.all.to_a
        $cache.set(key, result)
      ensure
        return result
      end
    end

    def get_exile_by_character_index(index)
      key = "exile_charindex_#{index.to_s}"
      begin
        result = $cache.get(key)
      rescue Memcached::NotFound
        result = Exile.where(:character_index => index).to_a.first
      ensure
        return result
      end
    end

    def get_triumvirate_by_team_index(index)
      key = "triumvirate_teamindex_#{index.to_s}"
      begin
        result = $cache.get(key)
      rescue Memcached::NotFound
        result = Triumvirate.where(:team_index => index).to_a.first
      ensure
        return result
      end
    end

    def get_stage_by_match_site(index)
      key = "stage_matchsite_#{index}"
      begin
        result = $cache.get(key)
      rescue Memcached::NotFound
        result = Stage.where(:match_site => index).to_a.first
      ensure
        return result
      end
    end

    # XXX Should memcache this, but it causes problems somehow
    def get_rite_by_id(id)
      rite = Rite[id]

      expanded_rite = {
        :rite => rite,
        :player_a => User[rite.player_a_id],
        :player_b => User[rite.player_b_id],
        :player_a_triumvirate => get_triumvirate_by_team_index(rite.player_a_triumvirate_team_index),
        :player_b_triumvirate => get_triumvirate_by_team_index(rite.player_b_triumvirate_team_index),
        :player_a_exiles => [
          get_exile_by_character_index(rite.player_a_exile_1_character_index),
          get_exile_by_character_index(rite.player_a_exile_2_character_index),
          get_exile_by_character_index(rite.player_a_exile_3_character_index),
        ],
        :player_b_exiles => [
          get_exile_by_character_index(rite.player_b_exile_1_character_index),
          get_exile_by_character_index(rite.player_b_exile_2_character_index),
          get_exile_by_character_index(rite.player_b_exile_3_character_index),
        ],
        :hosting_player => User[rite.hosting_player_id],
        :stage => get_stage_by_match_site(rite.stage_match_site),
        :label => rite.label,
      }

      return expanded_rite
    end

    def get_rites_won_by(player_id)
      return Rite.all.select { |r| r.winner_id == player_id }
    end

    def get_rites_lost_by(player_id)
      return Rite.all.select { |r| r.loser_id == player_id }
    end

    def img(path)
      return "#{S3_BUCKET}/img/#{path}"
    end
  end
end
