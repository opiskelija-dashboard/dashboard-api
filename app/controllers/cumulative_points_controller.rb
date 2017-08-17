class CumulativePointsController < ApplicationController
  def show
    course_id = params['course_id']
    if course_id.nil?
      render json: { errors:
      [
        {
          title: 'Missing required course_id',
          detail: 'Request address must be of the corm
                  /cumulative-points/<course-id>, where <course-id>
                  is the ID code of a TMC course.'
        }
      ]}, status: 400 # bad request
    end
    course_id = course_id.to_s

    cumulative_point = CumulativePoint.new(course_id, @token)
    render json: { data: cumulative_point.day_point_objects }
  end
end
