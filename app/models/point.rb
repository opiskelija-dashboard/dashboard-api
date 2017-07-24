class Point < ApplicationRecord
  validates :point_id, uniqueness: true

  def achieved_at
    self.created_at.to_s
  end
end
