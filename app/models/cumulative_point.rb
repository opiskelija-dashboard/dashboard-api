class CumulativePoint

  def initialize(course_id, token)
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore

    @course_id = course_id
    @token = token

    if (!@point_source.has_course_points?(@course_id))
      Rails.logger.debug("PointsStore didn't have points of course " + @course_id + ", fetching...");
      @point_source.update_course_points(@course_id, token)
    end
  end

  # Returns an array of {"day" => ..., "points" => ..., "average" => ...} hashes
  def day_point_objects
    users_points = PointsHelper.users_own_points(@point_source, @course_id, @token.user_id)
    everyones_points = PointsHelper.all_course_points(@point_source, @course_id)

    users_points_by_day = PointsHelper.daywise_points(users_points)
    everyones_points_by_day = PointsHelper.daywise_points(everyones_points)

    unique_users_count_by_day = PointsHelper.new_unique_users_per_day(everyones_points, PointsHelper.unique_users_globally(everyones_points))

    everyones_cumulative_points_by_day = PointsHelper.cumulativize(everyones_points_by_day)
    cumulative_unique_users_count_by_day = PointsHelper.cumulativize(unique_users_count_by_day)

    return_data = Array.new

    i = 0
    users_points = 0
    users_points_keys = users_points_by_day.keys
    cumulative_unique_users_count_by_day_keys = cumulative_unique_users_count_by_day.keys
    everyones_cumulative_points_by_day.each do |day, everyones_points|
      if users_points_by_day[users_points_keys[i]].nil?
        users_pointsIncrement = 0
      else users_pointsIncrement = users_points_by_day[users_points_keys[i]]
      end
      if unique_users_count = cumulative_unique_users_count_by_day[cumulative_unique_users_count_by_day_keys[i]].nil?
        unique_users_count = 0
      else unique_users_count = cumulative_unique_users_count_by_day[cumulative_unique_users_count_by_day_keys[i]]
      end
      everyones_average = everyones_points.to_f / unique_users_count
      users_points += users_pointsIncrement
      Rails.logger.debug("Date: " + cumulative_unique_users_count_by_day_keys[i].to_s + " Everyones_points: " + everyones_points.to_s + " \nUniques: " + unique_users_count.to_s)
      return_data.push({"date" => day, "users_points" => users_points, "everyones_average" => everyones_average})
      i += 1
    end
    return return_data
  end

end
