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
      :exiles => Exile.all.sort_by { |exile| exile.name },
      :triumvirates => Triumvirate.all.sort_by { |t| t.name },
      :users => User.all.sort_by { |u| u.username },
      :rites => Rite.all.sort_by { |rite| rite.id },
    })
  end

  get '/rites/?' do
    erb(:rites, :layout => :layout_default, :locals => {
      :rites => Rite.all.sort_by { |rite| rite.id },
    })
  end

  post '/rites/?' do
    # XXX Match.new; Match.save;
  end

  get '/rites/:id/?' do
    rite = Rite[params[:id]]
    #not_found! if not match

    erb(:rite_deatil, :layout => :layout_default, :locals => {
      :rite => match,
    })
  end

  get '/api/v1/users/?' do
    json_response!
  end

  get '/api/v1/triumvirates/?' do
    json_response!
  end
end
