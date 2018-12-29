require 'sinatra/base'
require 'sequel'
require 'rack'

DB = Sequel.connect(ENV["DB_URI"])

Dir['models/*.rb'].each { |model| require_relative model }
Exile.dataset = DB[:exiles]
InputMethod.dataset = DB[:input_methods]
Match.dataset = DB[:matches]
Rite.dataset = DB[:rites]
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
  end

  before do
    response["Content-Type"] = "text/html;charset=utf-8"
  end

  get '/' do
    erb(:index, :layout => :layout_default, :locals => {
      :exiles => Exile.all.sort_by { |exile| exile.exile_name },
      :triumvirates => Triumvirate.all.sort_by { |t| t.triumvirate_name },
      :users => User.all.sort_by { |u| u.user_username },
      :rites => Rite.all.sort_by { |rite| rite.rite_timestamp },
    })
  end

  get '/rites/?' do
    erb(:rites, :layout => :layout_default, :locals => {
      :rites => Rite.all.sort_by { |rite| rite.id },
    })
  end

  post '/rites/?' do
    # XXX Rite.new; Rite.save;
  end

  # XXX should be able to achieve this with joins, shouldn't need to make a
  # bazillion queries...
  #
  # XXX an alternative is to not use a SQL database at all!? O_o
  get '/rites/:id/?' do
    rite = Rite[params[:id].to_i]
    not_found if not rite

    player_a_triumvirate = Triumvirate[rite.player_a_triumvirate_id]
    player_a_exile_1 = Exile[rite.player_a_exile_1_id]
    player_a_exile_2 = Exile[rite.player_a_exile_2_id]
    player_a_exile_3 = Exile[rite.player_a_exile_3_id]

    erb(:rite_detail, :layout => :layout_default, :locals => {
      :rite => rite,
      :player_a_triumvirate => player_a_triumvirate,
      :player_a_exile_1 => player_a_exile_1,
      :player_a_exile_2 => player_a_exile_2,
      :player_a_exile_3 => player_a_exile_3,
    })
  end

  get '/api/v1/users/?' do
    json_response!
  end

  get '/api/v1/triumvirates/?' do
    json_response!
  end

  not_found do
    # XXX IMPLEMENTME
  end
end
