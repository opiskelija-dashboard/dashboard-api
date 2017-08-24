# Controls API-calls from routes to Cumulative Point
class CumulativePointsController < ApplicationController
  def show
    course_id = params['course_id']
    if course_id.nil?
      render json: error_for_course_id_nil, status: 400 # bad request
    end
    course_id = course_id.to_s
    cumulative_point = CumulativePoint.new(course_id, @token)
    render json: { data: cumulative_point.date_point_average_object }
  end

private

  def error_for_course_id_nil
    { errors: [
      {
        title: 'Missing required course_id',
        detail: 'Request address must be of the corm /cumulative-points/
        course/<course_id>, where <course-id> is the ID code of a TMC course.'
      }
      ] 
    }
  end
end
