class HeatmapsController < ApplicationController
  
  def initialize()
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore
    @course_id = params["course_id"]

    unless @point_source.has_course_points?(@course_id)
      Rails.logger.debug("PointsStore didn't have points of course #{@course_id}, fetching...");
      @point_source.update_course_points(@course_id, @token)
    end
  end

  # TODO: keskiarvon laskeminen mielekkäästi, sekä tämän tekeminen toimivaksi
  def get_all
    all_users_points = PointsHelper.all_course_points(@point_source, @course_id)
    points_by_day = PointsHelper.daywise_points(all_users_points)
    render json: { points_by_day }
  end

  # TODO: tämän tekeminen toimivaksi
  def get_current_user
    current_users_points = PointsHelper.users_own_points(@point_source, @course_id, @token.user_id)
    points_by_day = PointsHelper.daywise_points(current_users_points)
    render json: { points_by_day }
  end

end
