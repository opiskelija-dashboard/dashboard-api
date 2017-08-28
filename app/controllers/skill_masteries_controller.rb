# Controls API-calls to Skill Mastery related data.
class SkillMasteriesController < ApplicationController
  before_action :set_up, only: %i[current_user all combined]

  # GET /skill-mastery/course/:course_id/whereis/current
  def current_user
    render json: { data: @skill_mastery.current_user_skill_mastery }
  end

  # GET '/skill-mastery/course/:course_id/all'
  def all
    render json: { data: @skill_mastery.all_skill_mastery }
  end

  # GET '/skill-mastery/course/:course_id/combined'
  def combined
    render json: { data: @skill_mastery.combined_skill_mastery }
  end

  private

  def set_up
    course_id = params['course_id']
    if course_id.nil?
      render json: error_for_course_id_nil, status: 400 # bad request
    end
    course_id = course_id.to_s
    @skill_mastery = SkillMastery.new(course_id, @token)
  end

  def error_for_course_id_nil
    { errors: [
      {
        title: 'Missing required course_id',
        detail: 'Request address must be of the corm /cumulative-points/
        course/<course_id>, where <course-id> is the ID code of a TMC course.'
      }
    ] }
  end
end
