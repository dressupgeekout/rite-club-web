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

    # XXX should memcache this
    def get_rite_by_id(id)
      rite = Rite[id]

      expanded_rite = {
        :rite => rite,
        :player_a => User[rite.player_a_id],
        :player_b => User[rite.player_b_id],
        :player_a_triumvirate => Triumvirate[rite.player_a_triumvirate_id],
        :player_b_triumvirate => Triumvirate[rite.player_b_triumvirate_id],
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
      }
      return expanded_rite
    end

    def img(path)
      return "#{S3_BUCKET}/img/#{path}"
    end
  end
end
