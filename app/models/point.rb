class Point < ApplicationRecord
  validates :point_id, uniqueness: true
  belongs_to :submission

  def achieved_at
    self.created_at.to_s
  end
end
