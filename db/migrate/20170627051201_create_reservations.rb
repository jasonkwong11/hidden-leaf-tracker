class CreateReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :reservations do |t|
      t.string :room
      t.date :checkin
      t.date :checkout
      t.string :on_next_day
      t.string :vehicle, :default => nil
      t.string :notes
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
