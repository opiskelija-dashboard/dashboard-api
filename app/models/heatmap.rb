# Initialize PointsStore, course_id and token and provides methods to
# return calculated data based on PointsStores raw_data
class Heatmap
  def initialize(course_id, token)
    # Typically, point_source would be PointsStore, but for testing purposes
    # you might want to use MockPointsStore.
    config = Rails.configuration.points_store_class
    @point_source =
      config == 'MockPointsStore' ? MockPointsStore : PointsStore

    @course_id = course_id
    @token = token
    #return if @point_source.has_course_points?(@course_id)
    Rails.logger.debug("PointsStore didn't have points of course " +
      @course_id + ', fetching...')

    @point_source.update_course_points(@course_id, token) if
      @point_source.course_point_update_needed?(@course_id)
  end

  # GET /heatmap/courses/:course_id/all
  # OUTPUT hash {'date': 'everyones_average_points'}
  def everyones_points_average
    CalculatedPointsStore.daily_average_for_heatmap(@course_id)
  end

  # GET /heatmap/courses/:course_id/current-user
  # OUTPUT hash {'date': 'users_points'}
  def current_user
    current_users_points =
      PointsHelper.users_own_points(@point_source, @course_id, @token.user_id)
    points_by_day = PointsHelper.daywise_points(current_users_points)
    points_by_day
  end
end
