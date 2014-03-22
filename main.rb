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

  def card_image(card)
    "<img src='/images/cards/#{card[0]}_#{card[1]}.svg' class='card'>"
  end

end

before do 
  @show_buttons = true
end

get '/' do
  # session.delete(:player_name)
  if session[:player_name]
    redirect '/game'
  else
    redirect '/get_name'
  end
end

get '/get_name' do
  erb :get_name
end

post '/get_name' do
  if params[:player_name].empty?
    @problem = true
    halt erb :get_name
  end
  session[:player_name] = params[:player_name]
  session[:player_score] = 0
  session[:dealer_score] = 0
  redirect '/game'
end

get '/game' do
  @suits = ['hearts', 'clubs', 'diamonds', 'spades']
  @cards = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'jack', 'queen', 'king', 'ace']
  @turn = 'initial'
  session[:deck] = @suits.product(@cards).shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []

  initial_deal(session[:player_hand], session[:deck])
  initial_deal(session[:dealer_hand], session[:deck])

  player_total = get_total(session[:player_hand])
  
  if player_total == 21
    @show_buttons = false
    @message = "You've got Blackjack!"
    session[:player_score] += 1
  end
  
  erb :game
end

post '/game/player/hit' do
  deal_card(session[:player_hand], session[:deck])
  player_total = get_total(session[:player_hand])
  @turn = 'hit'
  
  if player_total == 21
    @show_buttons = false
    @message = "You've got Blackjack!"
    session[:player_score] += 1
  elsif player_total > 21
    @show_buttons = false
    @message = "Sorry, looks like you busted."
    session[:dealer_score] += 1
  end
  
  erb :game
end

post '/game/player/stay' do
  @show_buttons = false
  @message = "You've decided to stay"
  @turn = 'stay'
  # dealer turn
  if get_total(session[:dealer_hand]) < 17
    redirect '/game/dealer/hit'
  end
  
  erb :game
end

get '/game/dealer/hit' do
  dealer_total = get_total(session[:dealer_hand])
  @turn = 'stay'
  while dealer_total < 17
    deal_card(session[:dealer_hand], session[:deck])
  end

  if dealer_total == 21
    @message = "Sorry #{session[:player_name]}, but the dealer hit Blackjack. Better luck next time!"
    session[:dealer_score] += 1
  elsif dealer_total > 21
    @message = "#{session[:player_name]}, you won! The dealer busted with #{dealer_total}!"
    session[:player_score] += 1
  else
    #compare scores
    redirect '/game/dealer/stay'
  end
  erb :game
end

get '/game/dealer/stay' do
  dealer_total = get_total(session[:dealer_hand])
  player_total = get_total(session[:player_hand])
end




