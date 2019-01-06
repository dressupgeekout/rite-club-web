require 'erb'
require 'json'
require 'rack'
require 'sequel'
require 'sinatra/base'

begin
  $memcached_loaded = false
  require 'memcached'
  $memcached_loaded = true
rescue LoadError
  # OK
end

$memcached_loaded = false if ENV["NO_MEMCACHED"]

# Dummy class which pretends to be an interface to Memcached but in fact is
# not.
class FakeCache
  def initialize(*args, **kwargs); end;
  def get(*args, **kwargs); raise Memcached::NotFound; end;
  def set(*args, **kwargs); end;
end

if $memcached_loaded
  $cache = Memcached.new(ENV["MEMCACHED_URI"] || "localhost:11211")
else
  $cache = FakeCache.new
end

HERE = File.expand_path(__dir__)
DB = Sequel.connect(ENV["DB_URI"])

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
      :users => User.all.sort_by { |u| u.username },
      :rites => Rite.all.sort_by { |rite| rite.timestamp },
      :input_methods => static_get_all(InputMethod),
    })
  end

  # The strategy is to get all the "expanded" or "resolved" Rite objects
  # we're interested in from the cache.
  get '/rites/?' do
    rites = Rite.select(:id, :timestamp).reverse(:timestamp).limit(25).
      map { |rite| rite.id }.
      map { |id| get_rite_by_id(id) }

    erb(:rites, :layout => :layout_default, :locals => {
      :rites => rites,
    })
  end

  get '/rites/labels/?' do
    labels = Rite.select(:label).all.map { |r| r.label }.sort.uniq

    erb(:labels, :layout => :layout_default, :locals => {
      :labels => labels,
    })
  end

  get '/rites/labels/:label/?' do
    rites = Rite.where(:label => params[:label]).all

    erb(:label_detail, :layout => :layout_default, :locals => {
      :rites => rites,
      :label => params[:label],
    })
  end

  get '/rites/:id/?' do
    rite = get_rite_by_id(params[:id].to_i)

    if rite
      erb(:rite_detail, :layout => :layout_default, :locals => {
        :rite => rite,
      })
    else
      not_found
    end
  end

  get '/users/?' do
    erb(:users, :layout => :layout_default, :locals => {
      :users => User.all,
    })
  end

  get '/users/:username/?' do
    user = User.where(:username => params[:username]).to_a.first
    relevant_rites = Rite.where(Sequel.or(:player_a_id => user.id, :player_b_id => user.id,)).to_a

    erb(:user_detail, :layout => :layout_default, :locals => {
      :user => user,
      :relevant_rites => relevant_rites,
      :n_rites_conducted => relevant_rites.length,
    })
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
