require 'erb'
require 'json'
require 'memcached'
require 'rack'
require 'sequel'
require 'sinatra/base'

HERE = File.expand_path(__dir__)

DB = Sequel.connect(ENV["DB_URI"])
$cache = Memcached.new(ENV["MEMCACHED_URI"] || "localhost:11211")

# If S3_BUCKET is undefined, then use public/img instead:
S3_BUCKET = ENV["S3_BUCKET_URL"] || "/"

# Database models:
Dir["#{HERE}/../models/*.rb"].each { |model| require_relative model }
Exile.dataset = DB[:exiles]
InputMethod.dataset = DB[:input_methods]
Match.dataset = DB[:matches]
Rite.dataset = DB[:rites]
Stage.dataset = DB[:stages]
Triumvirate.dataset = DB[:triumvirates]
User.dataset = DB[:users]

######### ######### #########

class RiteClubWeb < Sinatra::Base
  configure do
    set :root, File.join(HERE, "..")
    enable :sessions
  end

  before do
    response["Content-Type"] = "text/html;charset=utf-8"
  end
end

require_relative 'helpers'

class RiteClubWeb
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

  get '/rites/:id/?' do
    rite = get_rite_by_id(params[:id].to_i)

    if rite
      erb(:rite_detail, :layout => :layout_default, :locals => rite)
    else
      not_found
    end
  end

  not_found do
    if json_response?
      render_json_response({"status" => "Not Found",})
    else
      erb(:not_found, :layout => :layout_default)
    end
  end
end

require_relative 'api'