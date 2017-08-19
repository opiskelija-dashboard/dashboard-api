class HeatmapsController < ApplicationController

  # GET /heatmap/courses/:course_id/all
  def get_everyones_points_average
    course_id = params["course_id"]
    if (course_id.nil?)
      render json: { "errors" => [
          {
            "title" => "Missing required course_id",
            "detail" => "Request address must be of the corm /heatmap/courses/<course_id>/all, where <course-id> is the ID code of a TMC course."
          }
        ]
      }, status: 400 # bad request
    end

    course_id = course_id.to_s
    heatmap_for_everyone = Heatmap.new(course_id, @token)
    render json: { "data" => heatmap_for_everyone.get_everyones_points_average }
  end
    

  # GET /heatmap/courses/:course_id/current-user
  def get_current_user
    course_id = params["course_id"]
    if (course_id.nil?)
      render json: { "errors" => [
          {
            "title" => "Missing required course_id",
            "detail" => "Request address must be of the corm /heatmap/courses/<course_id>/current-user, where <course-id> is the ID code of a TMC course."
          }
        ]
      }, status: 400 # bad request
    end

    course_id = course_id.to_s
    heatmap_for_current_user = Heatmap.new(course_id, @token)
    render json: { "data" => heatmap_for_current_user.get_current_user }
  end

  private

  def update_points_source_if_necessary(course_id, token)
    return if @point_source.has_course_points?(course_id)
    Rails.logger.debug("PointsStore didn't have points of course #{course_id}, fetching...")
    @point_source.update_course_points(course_id, token)
  end
end
