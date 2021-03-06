# Controls point_source update json messages.
class CoursePointsController < ApplicationController
  def initialize
    # Typically, point_source would be PointsStore, but for testing purposes
    # you might want to use MockPointsStore.
    config = Rails.configuration.points_store_class
    @point_source =
      config == 'MockPointsStore' ? MockPointsStore : PointsStore
  end

  # Update if necessary.
  # GET /course-data/:course_id/update
  def update
    course_id = params[:course_id].to_s

    if @point_source.course_point_update_needed?(course_id) == false
      render json: { data: "Points of course #{course_id} not updated because data isn't too old yet" }, status: 200 # Ok
      return
    end

    update_attempt = @point_source.update_course_points(course_id, @token)

    if update_attempt[:success]
      render json: { data: "OK, updated points of course #{course_id}" }, status: 200
    else
      errors = update_attempt[:errors]
      errors.push(
        title: "Unable to update points of course #{course_id}",
        detail: 'The update failed at the point source.'
      )
      render json: { errors: errors }, status: 500 # Server error
    end
  end
end
