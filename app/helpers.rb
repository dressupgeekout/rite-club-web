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
      end

      return result
    end

    def get_rite_by_id(id)
      key = "expanded_rite_#{id.to_s}"

      begin
        expanded_rite = $cache.get(key)
      rescue Memcached::NotFound
        rite = Rite[id]
        return rite if not rite

        # XXX I think I should fully expand/this to plan Hashes
        expanded_rite = {
          :rite => rite,
          :player_a => User[rite.player_a_id],
          :player_b => User[rite.player_b_id],
          :player_a_triumvirate => Triumvirate[rite.player_a_triumvirate_id],
          :player_b_triumvirate => Triumvirate[rite.player_b_triumvirate_id],
          :player_a_exile_1 => Exile[rite.player_a_exile_1_id],
          :player_a_exile_2 => Exile[rite.player_a_exile_2_id],
          :player_a_exile_3 => Exile[rite.player_a_exile_3_id],
          :player_b_exile_1 => Exile[rite.player_b_exile_1_id],
          :player_b_exile_2 => Exile[rite.player_b_exile_2_id],
          :player_b_exile_3 => Exile[rite.player_b_exile_3_id],
          :hosting_player => User[rite.rite_hosting_player_id],
        }

        $cache.set(key, expanded_rite)
      end
    end

    def img(path)
      return "#{S3_BUCKET}/img/#{path}"
    end
  end
end
