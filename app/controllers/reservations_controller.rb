class ReservationsController < ApplicationController
  def index
    @reservations = Reservation.all
  end

  def new

    @reservation = Reservation.new
  end

  def create
    @board = Board.find(params[:board_id])
    @reservation = @board.reservations.create(reservation_params)
    if @reservation.save
      flash[:notice] = "Reservation successfully created."
      redirect_to @board
    else
      flash[:notice] = "Please ensure all fields are filled in correctly"
      redirect_to new_board_reservation_path
    end
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  def edit
    @reservation = Reservation.find(params[:board_id])
  end

  def update
    @board = Board.find(params[:id])
    @reservation = Reservation.find(params[:board_id])
    if @reservation.update(reservation_params)
      flash[:notice] = "Reservation successfully edited!"
      redirect_to @board
    else
      flash[:notice] = "Please ensure all fields are filled in correctly"
      render 'edit'
    end
  end

  def destroy
    @reservation = Reservation.find(params[:board_id])
    @reservation.destroy
    flash[:notice] = "Reservation successfully deleted"
     
    @board = Board.find(params[:id])
    redirect_to @board
  end
end

private

  def reservation_params
    params.require(:reservation).permit(:board_id, :created_at, :updated_at, :notes, :vehicle, :on_next_day, :checkin, :checkout, :room, :customer)
  end  
