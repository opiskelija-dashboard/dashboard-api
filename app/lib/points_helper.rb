class PointsHelper

  def self.all_course_points(point_source, course_id)
    raw_points = point_source.course_points(course_id)
    return raw_points
  end

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

  def self.daywise_points(raw_points)
    points_by_day = Hash.new
    raw_points.each do |raw_point|
      point_content = raw_point["awarded_point"]
      # Remove the following line once 'created_at' is in the TMC server
      raw_point["awarded_point"]["created_at"] = "1970-01-01T12:00:00+0300" if (raw_point["awarded_point"]["created_at"].nil?)
      day = raw_point["awarded_point"]["created_at"].to_date
      points_by_day[day] = 0 if (points_by_day[day].nil?)
      points_by_day[day] += 1
    end
    return points_by_day
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

end
