# Class initializes Cumulative point with inputs: course_id and jwt-token,
# which offers logged in user_id
class CumulativePoint
  def initialize(course_id, token)
    # Typically, point_source would be PointsStore, but for testing purposes
    # you might want to use MockPointsStore.
    config = Rails.configuration.points_store_class
    @point_source =
      config == 'MockPointsStore' ? MockPointsStore : PointsStore

    @course_id = course_id
    @token = token
    #return if @point_source.has_course_points?(@course_id)

    # rubocop:disable Metrics/LineLength
    Rails.logger.debug("PointsStore didn't have points of course #{@course_id}, fetching...")
    # rubocop:enable Metrics/LineLength

    @point_source.update_course_points(@course_id, token) if
      @point_source.course_point_update_needed?(@course_id)
  end

  # Returns an array of
  # {"day" => [...], "points" => [...], "average" => [...]} hashes
  # Basically just returns PointsStores data in different format.
  # This format is required by the frontend, which prefers three
  # separate arrays instead of one single array of objects.
  def date_point_average_object(course_id)
    init_all(course_id)
    loop_cumulative_counts_by_day_and_make_final_result
  end

  private

  # Initializes data for return:
  # First gets raw_points from PointsStore and then
  # modifies that data for calculation needs
  def init_all(course_id)
    init_raw_points
    init_daywise_points
    init_data_for_everyone(course_id)
  end

  # Get raw_points to instance variables
  def init_raw_points
    @raw_users_points =
      PointsHelper.users_own_points(@point_source, @course_id, @token.user_id)
  end

  # Uses @raw_points and initialize daywise hashes to instance variables
  def init_daywise_points
    @users_points_by_day = PointsHelper.daywise_points(@raw_users_points)
  end

  def init_data_for_everyone(course_id)
    @everyones_cumulative_points_by_day =
      CalculatedPointsStore.everyones_cumulative_points_by_day(course_id)
    @cumulative_unique_users_count_by_day =
      CalculatedPointsStore.cumulative_unique_users_count_by_day(course_id)
  end
  

  def if_nil_return_zero(value)
    return 0 if value.nil?
    value
  end

  def jsonize(date, users_points, everyones_average,
              everyone_count, all_points_count)
    { 'date' => date,
      'users_points' => users_points,
      'everyones_average' => everyones_average,
      'everyone_count' => everyone_count,
      'all_points_count' => all_points_count }
  end

  # Loops instance variable @everyones_cumulative_points_by_day and
  # OUTPUTs Array of hashes based on @everyones_cumulative's information
  #   {
  #     'date' => date,
  #     'users_points' => users_points,
  #     'everyones_average' => everyones_average
  #    }
  # This is preferred format for frontend's needs, used in cumulative graph
  def loop_cumulative_counts_by_day_and_make_final_result
    return_data = []
    users_points = 0
    @everyones_cumulative_points_by_day.each do |date, points|
      users_points_increment = if_nil_return_zero(@users_points_by_day[date])
      unique_users_count =
        if_nil_return_zero(@cumulative_unique_users_count_by_day[date])
      everyones_average = points.to_f / unique_users_count
      users_points += users_points_increment
      return_data.push(jsonize(date, users_points,
                               everyones_average, unique_users_count, points))
    end
    return_data
  end
end
