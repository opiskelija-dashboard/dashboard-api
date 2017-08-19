# Class initializes Cumulative point with inputs: course_id and jwt-token,
# which offers logged in user_id
# Method date_point_average_object returns an array for frontend purposes
# with data {"date", "user's points", "average"}
class CumulativePoint
  def initialize(course_id, token)
    config = Rails.configuration.points_store_class
    @point_source =
      config == 'MockPointsStore' ? MockPointsStore : PointsStore

    @course_id = course_id
    @token = token

    return unless @point_source.has_course_points?(@course_id)
    Rails.logger.debug("PointsStore didn't have points of course " +
    @course_id + ', fetching...')
    @point_source.update_course_points(@course_id, token)
  end

  # Returns an array of
  # {"day" => ..., "points" => ..., "average" => ...} hashes
  def date_point_average_object
    init_all

    return_data = []
    i = 0
    users_points = 0

    @everyones_cumulative_points_by_day.each do |date, points|
      users_points_increment = if @users_points_by_day[date].nil?
                                 0
                               else @users_points_by_day[date]
                               end

      unique_users_count = if @cumulative_unique_users_count_by_day[date].nil?
                             0
                           else @cumulative_unique_users_count_by_day[date]
                           end
      everyones_average = points.to_f / unique_users_count
      users_points += users_points_increment
      return_data.push(
        'date' => date,
        'users_points' => users_points,
        'everyones_average' => everyones_average
      )
      i += 1
    end
    return_data
  end

  private

  def init_all
    init_raw_points
    init_daywise_points
    init_unique_users_count_by_day
    init_cumulative_arrays
  end

  def init_raw_points
    @raw_users_points =
      PointsHelper.users_own_points(@point_source, @course_id, @token.user_id)
    @raw_everyones_points =
      PointsHelper.all_course_points(@point_source, @course_id)
  end

  def init_daywise_points
    @users_points_by_day = PointsHelper.daywise_points(@raw_users_points)
    @everyones_points_by_day =
      PointsHelper.daywise_points(@raw_everyones_points)
  end

  def init_unique_users_count_by_day
    all_unique_users = PointsHelper.unique_users_globally(@raw_everyones_points)
    @unique_users_count_by_day =
      PointsHelper.new_unique_users_per_day(@raw_everyones_points,
                                            all_unique_users)
  end

  def init_cumulative_arrays
    @everyones_cumulative_points_by_day =
      PointsHelper.cumulativize(@everyones_points_by_day)
    @cumulative_unique_users_count_by_day =
      PointsHelper.cumulativize(@unique_users_count_by_day)
  end
end
