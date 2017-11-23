# -*- coding: utf-8 -*-
require './application.rb'

use Rack::Session::Cookie,
    :secret => (ENV['COOKIE_SECRET'] || '74y?W}LCxutk<H,0o,QJ]p!Öe{zF*x86')

use OmniAuth::Builder do
  options(:path_prefix => "/oauth")
  OauthProviders.each do |prov, opts|
    key, secret = ["KEY","SECRET"].map { |a| ENV["#{prov}_#{a}".upcase] }
    provider prov, key, secret, opts
  end
end

run Sinatra::Application
