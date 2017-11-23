require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'
require 'zlib'
require 'stringio'
require 'pry'
require 'json'
require 'fileutils'

if File.exists?(".env")
  require 'dotenv'
  Dotenv.load
end

require_relative 'lib/ruby_extensions'
Dir[File.join(File.dirname(__FILE__),'config', 'initializers','*.rb')].
  each { |a| require_relative a }

[
 ['lib'],
 ['models'],
].each do |path|
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end

Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks','*.rake')].each do |f|
  load f
end
