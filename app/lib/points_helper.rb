class PointsHelper

  def self.all_course_points(point_source, course_id)
    raw_points = point_source.course_points(course_id)
    return raw_points
  end

  def self.users_own_points(point_source, course_id, token)
    raw_points = point_source.course_points(course_id)

    user_points = Array.new
    current_user = token.user_id

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
      raw_point["awarded_point"]["created_at"] = "2007-07-14T14:51" if (raw_point["awarded_point"]["created_at"].nil?)
      day = raw_point["awarded_point"]["created_at"].to_date
      points_by_day[day] = 0 if (points_by_day[day].nil?)
      points_by_day[day] += 1
    end
    return points_by_day
  end

end
