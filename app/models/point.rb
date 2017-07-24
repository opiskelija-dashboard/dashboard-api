class Point < ApplicationRecord
  validates :point_id, uniqueness: true

  def total_points
    Point.all.count
  end
end
