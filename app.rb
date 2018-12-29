require 'sinatra/base'
require 'sequel'
require 'rack'

DB = Sequel.connect(ENV["DB_URI"])

Dir['models/*.rb'].each { |model| require_relative model }
Exile.dataset = DB[:exiles]
InputMethod.dataset = DB[:input_methods]
Match.dataset = DB[:matches]
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
      require Rack::Utils.escape_html(str)
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
      :triumvirates => Triumvirate.all,
      :users => User.all,
    })
  end

  get '/matches/?' do
  end

  post '/matches/?' do
  end

  get '/matches/:match_id/?' do
  end

  get '/api/v1/users/?' do
    json_response!
  end

  get '/api/v1/triumvirates/?' do
    json_response!
  end
end
