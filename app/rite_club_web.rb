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
require_relative 'main_routes'
require_relative 'api'
