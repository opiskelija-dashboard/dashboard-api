class PointsController < ApplicationController
  before_action :set_point, only: [:show, :update, :destroy]

  # Point specifics of all points of the current user as JSON.
  def index
    render json: Point.all
  end

  # Total point count of the current user as JSON.
  def total_points
    set_points("http://secure-wave-81252.herokuapp.com/points")

    string_to_render = "{
                          \"total_points\": #{Point.count}
                        }"

    render json: string_to_render
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