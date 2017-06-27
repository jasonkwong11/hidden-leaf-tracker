class CreateGuests < ActiveRecord::Migration[5.1]
  def change
    create_table :guests do |t|
      t.string :name
      t.date :checkin
      t.date :checkout
      t.string :vehicle, :default => nil
      t.string :notes
    end
  end
end
