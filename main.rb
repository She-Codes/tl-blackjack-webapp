require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

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

  def winner!(msg)
    @show_buttons = false
    @reveal = true
    @message = "#{session[:player_name]} wins! #{msg}"
    session[:player_score] += 1
    session[:player_money] += session[:bet_amount]
  end

  def loser!(msg)
    @show_buttons = false
    @reveal = true
    @message = "#{session[:player_name]} loses. #{msg}"
    session[:dealer_score] += 1
    session[:player_money] -= session[:bet_amount]
  end

  def tie!(msg)
    @show_buttons = false
    @reveal = true
    @message = "Nobody wins - it's a draw. #{msg}"
    session[:player_money] -= session[:bet_amount]
  end

end

before do 
  @show_buttons = true
end

get '/' do
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

  @legal_chars = []
  "a".upto("z") {|c| @legal_chars << c}
  params[:player_name].each_char do |c|
    if !@legal_chars.include? c.downcase 
      @problem = true
      halt erb :get_name
    end
  end 
  
  session[:player_name] = params[:player_name].capitalize
  session[:player_score] = 0
  session[:dealer_score] = 0

  redirect '/game'
end

get '/bet' do
  session[:player_money] = 500
  erb :bet_amount
end

post '/bet' do

  if params[:bet_amount].empty?
    @problem = true
    halt erb :bet_amount
  end

  @legal_chars = []
  "0".upto("9") {|n| @legal_chars << n}
  params[:bet_amount].each_char do |n|
    if !@legal_chars.include? n 
      @problem = true
      halt erb :bet_amount
    end
  end

  if !(1..session[:player_money]).include? params[:bet_amount].to_i
    @problem = true
    halt erb :bet_amount
  end

  session[:bet_amount] = params[:bet_amount].to_i

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
  
  if player_total == BLACKJACK_AMOUNT
    winner!("You've got Blackjack!")
  elsif dealer_total == BLACKJACK_AMOUNT
    loser!("Sorry, but the dealer wins with Blackjack.")
  elsif dealer_total == BLACKJACK_AMOUNT && player_total == BLACKJACK_AMOUNT
    tie!("The dealer also had #{dealer_total}.")
  end
  
  erb :game
end

post '/game/player/hit' do
  deal_card(session[:player_hand], session[:deck])
  player_total = get_total(session[:player_hand])
  @player_turn = 'hit'
  
  if player_total == BLACKJACK_AMOUNT
    winner!("You've got Blackjack!")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("Sorry, looks like you busted.")
  end
  
  erb :game
end

post '/game/player/stay' do
  redirect '/game/dealer'
end

get '/game/dealer' do
  @player_turn = 'stay'
  player_total = get_total(session[:player_hand])

  while get_total(session[:dealer_hand]) < DEALER_MIN_HIT
    deal_card(session[:dealer_hand], session[:deck])

    # @delay still reveals dealer's first card but sets a delay
    # if not set reveal class automatically set in template
    @delay = true  
  end

  dealer_total = get_total(session[:dealer_hand])
  if dealer_total == BLACKJACK_AMOUNT
    loser!("Sorry, but the dealer wins with Blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("The dealer busted with #{dealer_total}!")
  else
    #compare scores
    if dealer_total > player_total
      loser!("Sorry, but the dealer wins with #{dealer_total}.")
    elsif player_total > dealer_total
      winner!("The dealer loses with #{dealer_total}!")
    elsif player_total == dealer_total
      tie!("The dealer also had #{dealer_total}.")
    end
  end

  erb :game
end





