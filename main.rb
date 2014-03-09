require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  # session.delete(:player_name)
  if session[:player_name]
    redirect '/game'
  else
    erb :get_name
  end
end

# get '/get_name' do
#   erb :get_name
# end

post '/' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  @suits = ['hearts', 'clubs', 'diamonds', 'spades']
  @cards = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'jack', 'queen', 'king', 'ace']
  session[:deck] = @suits.product(@cards).shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []

  def deal_card(hand, deck)
    hand << deck.shift
  end

  def initial_deal (hand, deck)
    2.times do
      deal_card(hand, deck)
    end
  end

  initial_deal(session[:player_hand], session[:deck])
  initial_deal(session[:dealer_hand], session[:deck])
  erb :game
end





