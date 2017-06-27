class AddReservationIdToGuest < ActiveRecord::Migration[5.1]
  def change
    add_column :guests, :reservation_id, :integer
  end
end
