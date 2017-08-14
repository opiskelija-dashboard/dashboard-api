class MasteryPercentagesController < ApplicationController
  def skill_percentage_current
    course_id = params["course_id"]
    if (course_id.nil?)
      render json: { "errors" => [
          {
            "title" => "Missing required course_id",
            "detail" => "Request address must be of the corm /cumulative-points/<course-id>, where <course-id> is the ID code of a TMC course."
          }
        ]
      }, status: 400 # bad request
    end
    course_id = course_id.to_s

    @mastery_percentage = MasteryPercentage.new(course_id, @token)
    render json: @mastery_percentage
  end
end
