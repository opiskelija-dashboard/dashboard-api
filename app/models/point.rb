class Point < ApplicationRecord
  validates :point_id, uniqueness: true

  def total_points
    Point.count
  end
end
