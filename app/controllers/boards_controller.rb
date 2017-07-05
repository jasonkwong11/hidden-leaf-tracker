require 'dotenv'

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
    @reservations = @board.reservations.sort_by{ |r| r.room }
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
      client_id: "798648261019-05deia4vsv5l4ul9branekbeuapkp6vl.apps.googleusercontent.com",
      client_secret: "Jk3Im7WmB0iPk-xrR1rHXbpU",
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      redirect_uri: url_for(:action => :callback),
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

    @threads = service.list_user_threads('me', q: 'from:express@airbnb.com  subject:"reservation confirmed" new booking', max_results: 9999)
    id_array = @threads.threads.map {|t| t.id}

    id_array.each do |id|
      @message = service.get_user_message('me', id)
      reservation_hash = {
        customer: @message.payload.parts[0].body.data.split("\r\n")[4],
        room: @message.payload.parts[0].body.data.split("\r\n")[14],

        #convert below to Date
        #instead of hard-coding the exact index, make it more
        #flexible by finding the "Check-in" element then
        #checkin is that index + 1.
        #checkout is checkin + 3
        
        checkin: @message.payload.parts[0].body.data.split("\r\n")[19],
        checkout: @message.payload.parts[0].body.data.split("\r\n")[22]
      }

      reservation = Reservation.find_or_initialize_by(reservation_hash)
      
      require 'pry'
      binding.pry

      reservation.save
    end

    redirect_to '/'
    #iterate through threads, collecting the IDs in an array

    #iterate through the ids_array. for each array, make a call to the get_user_message API
    #take the message object and assign the parts needed for a reservation to a reservation_hash
    #use the reservation_hash to mass assign a new reservation object
      #...(use the pattern from auction-edge-test as an example)
      #...e.g: use: find_or_initialize

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
