class PointsController < ApplicationController
  before_action :set_point, only: [:show, :update, :destroy]

  # GET /points
  def index

    test_url = "http://localhost:3000/api/v8/courses/214/users/current/points"
    uri = URI.parse(test_url)
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

    render json: Point.first
    
  end

  # GET /points/1
  def show
    render json: @point
  end

  # POST /points
  def create
    @point = Point.new(point_params)

    if @point.save
      render json: @point, status: :created, location: @point
    else
      render json: @point.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /points/1
  def update
    if @point.update(point_params)
      render json: @point
    else
      render json: @point.errors, status: :unprocessable_entity
    end
  end

  # DELETE /points/1
  def destroy
    @point.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_point
      @point = Point.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def point_params
      params.require(:point).permit(:exercise_id, :point_id, :course_id, :user_id, :submission_id, :name)
    end
end
