class PointsController < ApplicationController
  before_action :set_point, only: [:show, :update, :destroy]

  # GET /api/v8/courses/214/users/current/points
  # Temporary GET /http://secure-wave-81252.herokuapp.com/points
  def index
  end

  def total_points
    url = "http://secure-wave-81252.herokuapp.com/points"
    set_points(url)

    render json: "{
                    \"total_points\": ${Point.count} 
                  }"
  end

  private

    def set_points(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      hash = JSON.parse response.body
      hash.each do |point|
        p = Point.new
        p.exercise_id = point["exercise_id"]
        p.point_id = point["awarded_point"]["id"]
        p.course_id = point["awarded_point"]["course_id"]
        p.user_id = point["awarded_point"]["user_id"]
        p.submission_id = point["awarded_point"]["submission_id"]
        p.name = point["awarded_point"]["name"]
        p.save
      end
    end

    # Only allow a trusted parameter "white list" through.
    def point_params
      params.require(:point).permit(:exercise_id, :point_id, :course_id, :user_id, :submission_id, :name)
    end
end
