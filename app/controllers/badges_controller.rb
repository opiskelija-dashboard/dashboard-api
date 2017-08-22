class BadgesController < ApplicationController
  # GET /user-badges/course/:course_id/earned
  def get_earned_in_course
    course_id = params["course_id"].to_s
    earned_badges = find_earned_in_course(course_id)
    render json: {"data" => earned_badges }
  end
  # GET /user-badges/course/:course_id/unearned
  def get_unearned_in_course
    course_id = params["course_id"].to_s
    earned_in_course = find_earned_in_course(course_id)
    all_badges_in_course = find_all_in_course(course_id)
    unearned_in_course = all_badges_in_course - earned_in_course
    render json: {"data" => unearned_in_course}
  end

  # GET /user-badges/global/earned
  def get_earned_global
    earned_badges = find_earned
  end

  # GET /user-badges/global/unearned
  def get_unearned_global
  end

  def find_earned_in_course(course_id)
    earned_in_course = []
    Badge.find_each do |badge|
      earned_in_course << badge.badge_def if (badge.course_id == course_id)
    end
    earned_in_course
  end

  def find_all_in_course(course_id)
    all_badges_in_course = []
    BadgeDef.find_each do |bdef|
      all_badges_in_course << bdef if (bdef.course_id == course_id)
    end
    all_badges_in_course 
  end

end
