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
end


private

  def board_params
    params.require(:board).permit(:name)
  end  
