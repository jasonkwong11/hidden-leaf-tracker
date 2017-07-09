class Reservation < ApplicationRecord
  belongs_to :board
  has_many :guests

  def days_stayed
    (self.checkout - self.checkin).to_i
  end
end
