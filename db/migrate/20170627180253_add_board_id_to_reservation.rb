class AddBoardIdToReservation < ActiveRecord::Migration[5.1]
  def change
    add_column :reservations, :board_id, :integer
  end
end
