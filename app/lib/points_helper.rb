class PointsHelper

  # Returns data from point_source (PointsStore) for all users
  def self.all_course_points(point_source, course_id)
    raw_points = point_source.course_points(course_id)
    return raw_points
  end

  # Returns data from point_source (PointsStore) for specified user
  def self.users_own_points(point_source, course_id, user_id)
    raw_points = point_source.course_points(course_id)

    user_points = Array.new
    current_user = user_id

    raw_points.each do |raw_point|
      point_content = raw_point["awarded_point"]
      point_user = point_content["user_id"]
      user_points.push(raw_point) if (point_user == current_user)
    end
    return user_points
  end

  # Returns point count per dates for given data
  # INPUT: Raw data from PointsSource (typically user or everyones)
  # OUTPUT: Hash with {"date" => "point_count"}
  def self.daywise_points(raw_points)
    points_by_day = Hash.new
    raw_points.each do |raw_point|
      point_content = raw_point["awarded_point"]
      raw_point["awarded_point"]["created_at"] = "1970-01-01T12:00:00+0300" if (raw_point["awarded_point"]["created_at"].nil?)
      day = raw_point["awarded_point"]["created_at"].to_date
      points_by_day[day] = 0 if (points_by_day[day].nil?)
      points_by_day[day] += 1
    end
    return points_by_day
  end

  # Given a hash of arrays, like so:
  # { "key1" => [a, b, c, b, a], "key2" => [c, c, c, c] }
  # returns a new hash, with the arrays replaced by the number of unique
  # elements in them, like so:
  # { "key1" => 3, "key2" => 1 }
  def self.unique_bucket_count(buckets)
    ubc = Hash.new
    buckets.each do |key, bucket|
      unique_elements = bucket.sort().uniq().length()
      ubc[key] = unique_elements
    end
    return ubc
  end

  # To calculate the daily average of points submitted, we need not
  # the count of how many users submitted that day, nor the cumulative
  # count of user-IDs who have submitted so far, but the maximum amount
  # of unique users who received points.
  def self.new_unique_users_per_day(raw_points, unique_users)
    daybuckets = Hash.new
    # First, we chuck the users who submitted points into day-buckets.
    raw_points.each do |raw_point|
      day = raw_point["awarded_point"]["created_at"].to_date
      user_id = raw_point["awarded_point"]["user_id"]
      if unique_users.include?(user_id)
        daybuckets[day] = Array.new if (daybuckets[day].nil?)
        daybuckets[day].push(user_id)
        unique_users.delete(user_id)
      else
        daybuckets[day] = Array.new if (daybuckets[day].nil?)
      end
    end
    # Then, we sort and uniq all the day-buckets, and finally,
    # we grab the size of each day-bucket.
    unique_users_by_day = unique_bucket_count(daybuckets)
    return unique_users_by_day
  end

  # INPUT: raw-points as returned by PointsStore.course_points
  # OUTPUT: hash of format: { "date" => integer, "date" => integer },
  # where dates are ISO-8601 week dates, as returned by strftime("%G-W%V")
  def self.unique_users_per_week(raw_points)
    weekbuckets = Hash.new
    raw_points.each do |raw_point|
      date_obj = Date.iso8601(raw_point["awarded_point"]["created_at"])
      iso_week_date = date_obj.strftime("%G-W%V") # e.g. 2017-W33
      weekbuckets[iso_week_date] = Array.new if (weekbuckets[iso_week_date].nil?)
      user_id = raw_point["awarded_point"]["user_id"]
      weekbuckets[iso_week_date].push(user_id)
    end
    unique_users_per_week = unique_bucket_count(weekbuckets)
    return unique_users_per_week
  end


  # Returns unique users from the 
  # INPUT: Raw "point_source.course_points()" json
  # OUTPUT: Array of unique user_ids
  def self.unique_users_globally(raw_points) 
    users_in_array = Array.new
    raw_points.each do |raw_point|
      user_id = raw_point["awarded_point"]["user_id"]
      unless users_in_array.include?(user_id)
        users_in_array.push(user_id)  
      end
    end
    return users_in_array
  end

  # TODO: comment this 
  def self.cumulativize(data)
    if (data.nil? || data.length == 0)
      return Hash.new
    end
    days = data.keys
    days.sort!
    cumulative_data = Hash.new
    cumulative_data[days[0]] = data[days[0]]
    i = 1
    max = days.length
    while (i < max)
      today = days[i].nil? ? 0 : days[i]
      yesterday = days[i - 1].nil? ? 0 : days[i - 1]
      cumulative_data[today] = data[today] + cumulative_data[yesterday]
      i += 1
    end
    return cumulative_data
  end
end