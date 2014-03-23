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
  @player_turn = 'initial'
  session[:deck] = @suits.product(@cards).shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []

  initial_deal(session[:player_hand], session[:deck])
  initial_deal(session[:dealer_hand], session[:deck])

  player_total = get_total(session[:player_hand])
  dealer_total = get_total(session[:dealer_hand])
  
  if player_total == 21
    @show_buttons = false
    @message = "#{session[:player_name]}, you've got Blackjack!"
    @reveal = true
    session[:player_score] += 1
  elsif dealer_total == 21
    @show_buttons = false
    @message = "Sorry #{session[:player_name]}, you lose - the dealer wins with Blackjack."
    @reveal = true
    session[:dealer_score] += 1
  elsif dealer_total == player_total
    @show_buttons = false
    @message = "Sorry #{session[:player_name]}, this hand is a draw - the dealer also had #{dealer_total} so nobody wins."
    @reveal = true
  end
  
  erb :game
end

post '/game/player/hit' do
  deal_card(session[:player_hand], session[:deck])
  player_total = get_total(session[:player_hand])
  @player_turn = 'hit'
  
  if player_total == 21
    @show_buttons = false
    @message = "You've got Blackjack!"
    @reveal = true
    session[:player_score] += 1
  elsif player_total > 21
    @show_buttons = false
    @message = "Sorry, looks like you busted."
    @reveal = true
    session[:dealer_score] += 1
  end
  
  erb :game
end

post '/game/player/stay' do
  @show_buttons = false
  @message = "You've decided to stay"
  @player_turn = 'stay'
  player_total = get_total(session[:player_hand])
  
  while get_total(session[:dealer_hand]) < 17
    deal_card(session[:dealer_hand], session[:deck])
    @delay = true
  end

  dealer_total = get_total(session[:dealer_hand])
  if dealer_total == 21
    @message = "Sorry #{session[:player_name]}, but the dealer hit Blackjack. Better luck next time!"
    session[:dealer_score] += 1
  elsif dealer_total > 21
    @message = "#{session[:player_name]}, you win! The dealer busted with #{dealer_total}!"
    session[:player_score] += 1
  else
    #compare scores
    if dealer_total > player_total
      @message = "Sorry #{session[:player_name]}, the dealer wins with #{dealer_total}."
      session[:dealer_score] += 1
    elsif player_total > dealer_total
      @message = "#{session[:player_name]}, you win! The dealer loses with #{dealer_total}."
      session[:player_score] += 1
    elsif player_total == dealer_total
      @message = "Sorry #{session[:player_name]}, the game is a draw, the dealer also had #{dealer_total} so nobody wins this hand."
    end
  end
  erb :game
end






