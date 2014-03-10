require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do
  def get_total(hand)
    total = 0
    arr = hand.map{|element| element[1]}
    arr.each do |value|
      if value == 'ace'
        total < 11 ? total += 11 : total += 1
      else
        total += (value.to_i == 0 ? 10 : value)
      end
    end
    total
  end

  def deal_card(hand, deck)
    hand << deck.shift
  end

  def initial_deal(hand, deck)
    2.times do
      deal_card(hand, deck)
    end
  end 

  # def card_image(card)
  #   '<img src="/images/cards/'+<%= card[0] %>+'_'+<%= card[1] %>+'.jpg">'
  # end

end

before do 
  @show_buttons = true
end

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

  initial_deal(session[:player_hand], session[:deck])
  initial_deal(session[:dealer_hand], session[:deck])
  erb :game
end

post '/game/player/hit' do
  deal_card(session[:player_hand], session[:deck])
  if get_total(session[:player_hand]) > 21
    @show_buttons = false
    @error = "Sorry, looks like you busted."
  elsif get_total(session[:player_hand]) == 21
    @show_buttons = false
    @success = "You've got Blackjack!"
  end
  
  erb :game
end

post '/game/player/stay' do
  @show_buttons = false
  @success = "You've decided to stay"
  # dealer turn
  # if get_total(session[:dealer_hand]) < 17
  #   deal_card(session[:dealer_hand], session[:deck])
  # end
  erb :game
end





