class CumulativePoint

  #URLS - Change these to the correct ones when possible.
  CURRENT_USER_POINTS_ENDPOINT = '/courses/:course_id/users/current/points'
  ALL_USER_POINTS_ENDPOINT = '/courses/:course_id/points'
  CURRENT_USER_SUBMISSIONS_ENDPOINT = '/courses/:course_id/users/current/submissions'

  def initialize(course_id, token)
    @course_id = course_id
    @token = token
    Rails.logger.debug(@token.user_id)

    if (!PointsStore.has_course_points?(@course_id))
      Rails.logger.debug("PointsStore didn't have points of course " + @course_id + ", fetching...");
      PointsStore.update_course_points(@course_id, token)
    end

  end

  def all_course_points
    raw_points = PointsStore.course_points(@course_id)
    return raw_points
  end

  def users_own_points
    raw_points = PointsStore.course_points(@course_id)

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
      day = point_content["created_at"].to_date
      points_by_day[day] = 0 if (points_by_day[day].nil?)
      points_by_day[day] += 1
    end
    return points_by_day
  end

  def daywise_user_counts(raw_points)
    users_by_day = Hash.new
    raw_points.each do |raw_point|
      point_content = raw_point["awarded_point"]
      user = point_content["user_id"]
      users_by_day[day] = Array.new if (users_by_day[day].nil?)
      users_by_day[day].push(user)
    end
    user_counts_by_day = Hash.new
    users_by_day.each do |day, user_array|
      count = user_array.sort().uniq().length()
      user_counts_by_day[day] = count
    end
    return user_counts_by_day
  end

  def cumulativize_points(points_by_day)
    days = points_by_day.keys
    cumulative_points_by_day = Hash.new
    cumulative_points_by_day[days[0]] = points_by_day[days[0]]
    i = 1
    max = days.length
    while (i < max)
      today = days[i]
      yesterday = days[i - 1]
      cumulative_points_by_day[today] = points_by_day[today] + cumulative_points_by_day[yesterday]
    end
    return cumulative_points_by_day
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
    user_counts_by_day = daywise_user_counts(all_points)
    # this isn't exactly right: the result of our discussion is that
    # we need the maximum number of unique users so far, which cannot
    # be directly calculated from user_counts_by_day
    days = points_by_day.keys()
    average_by_day = Hash.new
    days.each do |day|
      points = cumulative_points_by_day[day]
      user_count = user_counts_by_day[day]
      if (user_count == 0)
        average_by_day[day] = 0
      else
        average_by_day[day] = points / user_count
      end
    end
    return average_by_day
  end


  # Returns hash: keys = days, values = points
  def hash_for_days_and_points
    points = user_points[0]
    submissions = get_submissions

    # Adds every submissions created_at to an array and sorts it.
    days = []
    points.each do |point|
      days << submissions[point.submission_id].created_at.to_date
    end
    days = days.sort

    # Change these to correspond to the correct TMC API earliest and latest submissions.
    day = days.first

    # Sets a hash with dates from first to last submission dates.
    hash = {}
    begin
      hash["#{day}"] = 0
      day += 1
    end until day > days.last

    # Adds the amount of submissions made to each day.
    i = 0
    begin
      hash["#{days[i]}"] = hash["#{days[i]}"] + 1
      i += 1
    end until i == days.count

    hash
  end

  # Returns days of the hash_for_days_and_points hash.
  def days
    hash_for_days_and_points.keys
  end

  # Returns points
  def points
    hash = hash_for_days_and_points

    points = []
    points[0] = hash.values[0]

    # Makes cumulative array of points from hash_for_days_and_points hash.
    i = 1
    begin
      points[i] = points[i - 1] + hash.values[i]
      i += 1
    end until i == hash.length

    points
  end

  def average
    points_and_users = all_points
    (all_points[0].count / all_points[1].count.to_f).round(2)
  end
end
