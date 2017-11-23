require 'yaml'
require 'active_record'
require 'active_support'
require 'pg'

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.establish_connection
  ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['RACK_ENV'] == 'development'

  Dir[File.join(File.dirname(__FILE__), '..','..','models','*.rb')].each do |f|
    require_relative f
  end
end
