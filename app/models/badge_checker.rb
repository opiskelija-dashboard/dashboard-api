class BadgeChecker
  # For badge(s): 1
  def get_current_user_point_count
    c = CumulativePoint.user_points
    c.count
  end
end