require 'erb'
require 'json'
require 'memcached'
require 'rack'
require 'sequel'
require 'sinatra/base'

DB = Sequel.connect(ENV["DB_URI"])
$cache = Memcached.new(ENV["MEMCACHED_URI"] || "localhost:11211")

Dir['models/*.rb'].each { |model| require_relative model }
Exile.dataset = DB[:exiles]
InputMethod.dataset = DB[:input_methods]
Match.dataset = DB[:matches]
Rite.dataset = DB[:rites]
Stage.dataset = DB[:stages]
Triumvirate.dataset = DB[:triumvirates]
User.dataset = DB[:users]

#########

class PyreMatchDb < Sinatra::Base
  configure do
    set :root, __dir__
    enable :sessions
  end

  helpers do
    def h(str)
      return Rack::Utils.escape_html(str)
    end

    def json_response!
      response["Content-Type"] = "application/json;charset=utf-8"
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
  end

  before do
    response["Content-Type"] = "text/html;charset=utf-8"
  end

  get '/' do
    erb(:index, :layout => :layout_default, :locals => {
      :exiles => static_get_all(Exile),
      :triumvirates => static_get_all(Triumvirate),
      :stages => static_get_all(Stage),
      :users => User.all.sort_by { |u| u.user_username },
      :rites => Rite.all.sort_by { |rite| rite.rite_timestamp },
      :input_methods => static_get_all(InputMethod),
    })
  end

  get '/rites/?' do
    erb(:rites, :layout => :layout_default, :locals => {
      :rites => Rite.all.sort_by { |rite| rite.id },
    })
  end

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
      :rite_talismans_enabled => rite['talismans_enabled'],
      :rite_masteries_allowed => rite['masteries_allowed'],
      :rite_player_a_pyre_health => playera['pyre_health'],
      :rite_player_b_pyre_health => playerb['pyre_health'],
      :rite_timestamp => Time.now, # XXX should be when the rite started
      :rite_hosting_player_id => playera['host'] ? playera['id'] : playerb['id'],
      :rite_duration => rite['duration'],
      :player_a_exile_1_id => playera['exiles'][0]['id'],
      :player_a_exile_2_id => playera['exiles'][1]['id'],
      :player_a_exile_3_id => playera['exiles'][2]['id'],
      :player_b_exile_1_id => playerb['exiles'][0]['id'],
      :player_b_exile_2_id => playerb['exiles'][1]['id'],
      :player_b_exile_3_id => playerb['exiles'][2]['id'],
    }

    rite = Rite.new(out_obj)

    if not rite.valid?
      # XXX 400
    end

    rite.save
    status 201 # XXX Created
    # XXX json_obj out
  end

  # XXX should be able to achieve this with joins, shouldn't need to make a
  # bazillion queries...
  #
  # XXX an alternative is to not use a SQL database at all!? O_o
  get '/rites/:id/?' do
    rite = Rite[params[:id].to_i]
    not_found if not rite

    erb(:rite_detail, :layout => :layout_default, :locals => {
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
    })
  end

  get '/api/v1/users/?' do
    json_response!
  end

  get '/api/v1/triumvirates/?' do
    json_response!
  end

  get '/api/v1/stages/?' do
    json_response!
  end

  get '/api/v1/exiles/?' do
    json_response!
  end

  get '/api/v1/talismans/?' do
    json_response!
  end

  get '/api/v1/input_methods/?' do
    json_response!
  end

  not_found do
    # XXX IMPLEMENTME
  end
end
