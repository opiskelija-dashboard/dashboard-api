class Heatmap

  def initialize(course_id, token)
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore

    @course_id = course_id
    @token = token

    if (!@point_source.has_course_points?(@course_id))
      Rails.logger.debug("PointsStore didn't have points of course " + @course_id + ", fetching...");
      @point_source.update_course_points(@course_id, token)
    end
  end

  # Returns a hash of current user's point counts {"day" => ..., "points" => ...}
  def get_current_users_point_count_per_day
    user_points = PointsHelper.users_own_points(@point_source, @course_id, @token)
    points_by_day = PointsHelper.daywise_points(user_points)
    return points_by_day
  end

  # Returns a hash of all users' point counts {"day" => ..., "points" => ...}
  def get_current_users_point_count_per_day
    all_users_points = PointsHelper.all_course_points(@point_source, @course_id)
    points_by_day = PointsHelper.daywise_points(all_users_points)
    return points_by_day
  end
end
