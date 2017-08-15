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
    user_points = users_own_points()
    points_by_day = daywise_points(user_points)
    cumulative_points_by_day = cumulativize_points(points_by_day)
    return_data = Array.new
    cumulative_points_by_day.each do |day, points|
      return_data.push({"day" => day, "points" => points})
    end
    return return_data
  end

  def average_points_by_day
    all_points = all_course_points()
    cumulative_points_by_day = cumulativize_points(daywise_points(all_points))

    # To calculate the daily average of points submitted, we need not
    # the count of how many users submitted that day, nor the cumulative
    # count of user-IDs who have submitted so far, but the maximum amount
    # of unique users who received points.
    daybuckets = Hash.new
    # First, we chuck the users who submitted points into day-buckets.
    all_points.each do |raw_point|
      day = raw_point["awarded_point"]["created_at"].to_date
      user_id = raw_point["awarded_point"]["user_id"]
      daybuckets[day] = Array.new if (daybuckets[day].nil?)
      daybuckets[day].push(user_id)
    end
    # Then, we cumulate the day-buckets, so that the bucket of day N
    # also contains the contents of day-bucket N-1.
    # We use cumulativize_points because it does exactly what we want:
    # just mentally do s/points/daybuckets/
    daybuckets = cumulativize_points(daybuckets)
    # Then, we sort and uniq all the day-buckets, and finally,
    # we grab the size of each day-bucket.
    user_counts_by_day = Hash.new
    daybuckets.each do |day, bucket|
      user_counts_by_day[day] = bucket.sort().uniq().length()
    end

    daily_average = Hash.new
    days = user_counts_by_day.keys().sort()
    days.each do |day|
      points = cumulative_points_by_day[day]
      user_count = user_counts_by_day[day]
      if (user_count == 0)
        daily_average[day] = 0
      else
        daily_average[day] = points / user_count
      end
    end

    return daily_average
  end


  private


  def all_course_points
    raw_points = @point_source.course_points(@course_id)
    return raw_points
  end

  def users_own_points
    raw_points = @point_source.course_points(@course_id)

    user_points = Array.new
    current_user = @token.user_id

    raw_points.each do |raw_point|
      point_content = raw_point["awarded_point"]
      point_user = point_content["user_id"]
      user_points.push(raw_point) if (point_user == current_user)
    end

    return user_points
  end

  def daywise_points(raw_points)
    points_by_day = Hash.new
    raw_points.each do |raw_point|
      point_content = raw_point["awarded_point"]
      # Remove the following line once 'created_at' is in the TMC server
      raw_point["awarded_point"]["created_at"] = "2007-07-14T14:51" if (raw_point["awarded_point"]["created_at"].nil?)
      day = raw_point["awarded_point"]["created_at"].to_date
      points_by_day[day] = 0 if (points_by_day[day].nil?)
      points_by_day[day] += 1
    end
    return points_by_day
  end

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
