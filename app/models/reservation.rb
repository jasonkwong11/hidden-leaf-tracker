class Reservation < ApplicationRecord
  belongs_to :board
  has_many :guests
end
