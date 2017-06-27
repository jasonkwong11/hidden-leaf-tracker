class ReservationsController < ApplicationController
  def index
    @reservations = Reservation.all
  end

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      flash[:notice] = "Reservation successfully created."
      redirect_to @reservation
    else
      flash[:notice] = "Please ensure all fields are filled in correctly"
      redirect_to new_reservation_path
    end
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  def edit
    @reservation = Reservation.find(params[:id])
  end

  def update
    @reservation = Reservation.find(params[:id])
    if @reservation.update(reservation_params)
      flash[:notice] = "Reservation successfully edited!"
      redirect_to @reservation
    else
      flash[:notice] = "Please ensure all fields are filled in correctly"
      render 'edit'
    end
  end

  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy
    redirect_to '/reservations'
  end
end

private

  def reservation_params
    params.require(:reservation).permit(:board_id, :created_at, :updated_at, :notes, :vehicle, :on_next_day, :checkin, :checkout, :room)
  end  
