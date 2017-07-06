require 'dotenv'
require 'date'

class BoardsController < ApplicationController
  def index
    @boards = Board.all
  end

  def new
    @board = Board.new
  end

  def create
    @board = Board.new(board_params)
    if @board.save
      flash[:notice] = "Board successfully created."
      redirect_to @board
    else
      flash[:notice] = "Please ensure all fields are filled in correctly"
      redirect_to new_board_path
    end
  end

  def show
    @board = Board.find(params[:id])
    @reservations = @board.reservations.sort_by{ |r| [r.room, r.checkout] }
  end

  def edit
    @board = Board.find(params[:id])
  end

  def update
    @board = Board.find(params[:id])
    if @board.update(board_params)
      flash[:notice] = "Board successfully edited!"
      redirect_to @board
    else
      flash[:notice] = "Please ensure all fields are filled in correctly"
      render 'edit'
    end
  end

  def destroy
    @board = Board.find(params[:id])
    @board.destroy
    redirect_to '/boards'
  end

  def delete_old
    @board = Board.find(params[:format])
    @board.reservations.each {|r| r.destroy if r.checkout < Date.today}
    @board.save
    redirect_to @board
  end

  def redirect

    client = Signet::OAuth2::Client.new({
      client_id: "798648261019-05deia4vsv5l4ul9branekbeuapkp6vl.apps.googleusercontent.com",
      client_secret: "Jk3Im7WmB0iPk-xrR1rHXbpU",
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
      redirect_uri: url_for(:action => :callback)
    })

    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new({
      client_id: "798648261019-j5bcc051gmmq2556kdiddfjhlmsi9s0s.apps.googleusercontent.com",
      client_secret: "Td7Zmj9RtU9qlwjAu3jz5t92",
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      redirect_uri: url_for(:action => :callback) || window.location.origin || window.location.protocol + '//' + window.location.host + '/' + oauth2callback,
      code: params[:code]
    })

    response = client.fetch_access_token!

    session[:access_token] = response['access_token']

    redirect_to url_for(:action => :emails)
  end

  def emails
    client = Signet::OAuth2::Client.new(access_token: session[:access_token])

    service = Google::Apis::GmailV1::GmailService.new


    access_token = AccessToken.new(session[:access_token])

    service.authorization = access_token

    @threads = service.list_user_threads('me', q: 'from:express@airbnb.com  subject:"reservation confirmed" new booking', max_results: 35)
    id_array = @threads.threads.map {|t| t.id}

    id_array.each do |id|
      @message = service.get_user_message('me', id)

      email_array = @message.payload.parts[0].body.data.split("\r\n").delete_if {|x| x == "" }

      customer_index = 3
      checkin_index = email_array.index("Check-in") + 1
      checkout_index = email_array.index("Checkout") + 1
      room_index = (email_array.index("-"*71)) + 1

      reservation_hash = {
        customer: email_array[customer_index],
        room: email_array[room_index],
        checkin: Date.parse(email_array[checkin_index]),
        checkout: Date.parse(email_array[checkout_index])
      }
      tacoma_board = Board.find_or_create_by(name: "Tacoma")
      seatac_board = Board.find_or_create_by(name: "SeaTac")

      if reservation_hash[:room].include?("Tacoma")
        reservation_hash[:room] = reservation_hash[:room][-2..-1]
        tacoma_board.reservations.find_or_create_by(reservation_hash) if reservation_hash[:checkout] >= Date.today
      end

      if reservation_hash[:room].include?("Airport")
        reservation_hash[:room] = reservation_hash[:room][-1]
        seatac_board.reservations.find_or_create_by(reservation_hash) if reservation_hash[:checkout] >= Date.today
      end
    end
    redirect_to '/'
  end
end

class AccessToken
  attr_reader :token
  def initialize(token)
    @token = token
  end

  def apply!(headers)
    headers['Authorization'] = "Bearer #{@token}"
  end
end

private

  def board_params
    params.require(:board).permit(:name)
  end  
