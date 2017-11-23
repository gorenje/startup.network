require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/streaming'
require 'sinatra/reloader'
require 'cgi'
require 'json'
require 'digest/md5'
require 'zlib'
require 'stringio'
require 'haml'
require 'sinatra/support/numeric'

require 'omniauth'
require 'omniauth-github'
require 'omniauth-xing'
require 'omniauth-linkedin-oauth2'
require 'omniauth-twitter'
require 'omniauth-facebook'
require 'omniauth-google-oauth2'

register Sinatra::Numeric

if File.exists?(".env")
  require 'dotenv'
  Dotenv.load
end

# RAILS_ENV is set via unicorn in production and used
# by test_helper to also set the environment.
set(:environment,   ENV['RACK_ENV']) unless ENV['RACK_ENV'].nil?
set :server,        :thin
set :port,          (ENV['PORT'] || 2343).to_i
set :public_folder, Proc.new { File.join(root, "public") }
set :logging, true

set :raise_errors, true
set :show_exceptions, false
set :dump_errors, true

if settings.environment == "development"
  require 'pry'
  require 'sinatra/reloader'
end

require_relative 'lib/ruby_extensions'
Dir[File.join(File.dirname(__FILE__),'config', 'initializers','*.rb')].
  each { |a| require_relative a }

[
 ['routes'],
 ['lib'],
 ['models'],
].each do |path|
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end

helpers do
  include ViewHelpers
end

before do
  redirect("https://#{request.host}") if redirect_host_to_ssl?
  redirect("https://www.#{request.host}") if redirect_host_to_www?
end
