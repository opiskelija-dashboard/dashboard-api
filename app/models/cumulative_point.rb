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

  # Returns an array of {"day" => ..., "points" => ...} hashes
  def day_point_objects
    user_points = PointsHelper.users_own_points(@point_source, @course_id, @token.user_id)
    all_points = PointsHelper.all_course_points(@point_source, @course_id)

    points_by_day = PointsHelper.daywise_points(user_points)
    all_points_by_days = PointsHelper.daywise_points(all_points)

    cumulative_all_points_by_day = cumulativize_points(all_points_by_days)

    return_data = Array.new
    i = 0
    points = 0
    point_keys = points_by_day.keys
    cumulative_all_points_by_day.each do |day, average|
      if points_by_day[point_keys[i]].nil?
        pointsIncrement = 0
      else pointsIncrement = points_by_day[point_keys[i]]
      end
      points += pointsIncrement
      return_data.push({"day" => day, "points" => points, "average" => average})
      i += 1
    end
    return return_data
  end

  private

  def cumulativize_points(points_by_day)
    if (points_by_day.nil? || points_by_day.length == 0)
      return Hash.new
    end

    days = points_by_day.keys
    days.sort!
    cumulative_points_by_day = Hash.new
    cumulative_points_by_day[days[0]] = points_by_day[days[0]]
    i = 1
    max = days.length
    while (i < max)
      today = days[i]
      yesterday = days[i - 1]
      cumulative_points_by_day[today] = points_by_day[today] + cumulative_points_by_day[yesterday]
      i += 1
    end
    return cumulative_points_by_day
  end

end
