require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :get_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end





