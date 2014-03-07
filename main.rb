require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  "<p>Hi Nikia!</p>"
end

get '/nikiashaw' do
  erb :nstemplate
end

get '/nested-template' do
  erb :"/stuff/nested"
end



