class BadgesController < ApplicationController
  
  # GET /user-badges/course/:course_id/earned
  def get_earned_in_course
    course_id = params["course_id"].to_i
    earned_badges = find_earned_in_course(course_id)
    render json: {"data" => earned_badges }
  end
  
  # GET /user-badges/course/:course_id/unearned
  def get_unearned_in_course
    course_id = params["course_id"].to_i  
    earned_in_course = find_earned_in_course(course_id)
    all_badges_in_course = find_all_in_course(course_id)
    unearned_in_course = all_badges_in_course - earned_in_course
    render json: {"data" => unearned_in_course}
  end
  
  # GET /user-badges/global/earned
  def get_earned_global
    earned_badges = find_all_global_earned
    render json: {"data" => earned_badges}
  end
  
  # GET /user-badges/global/unearned
  def get_unearned_global
    all_global_badges = find_all_global_badges
    earned_badges = find_all_global_earned
    unearned = all_global_badges - earned_badges
    render json: {"data" => unearned}
  end
  
  # Returns badges user has done in given course
  def find_earned_in_course(course_id)
    earned_in_course = []
    Badge.find_each do |badge|
      course_is_right = badge.course_id == course_id
      user_is_right = badge.user_id == @token.user_id.to_i
      earned_in_course << badge.badge_def if (course_is_right && user_is_right)
    end
    earned_in_course
  end
  
  # Returns all possible badges in given course
  def find_all_in_course(course_id)
    all_badges_in_course = []
    BadgeDef.find_each do |bdef|
      all_badges_in_course << bdef if (course_id == bdef.course_id)
    end
    all_badges_in_course 
  end
  
  # Returns all badge user has earned in every course
  def find_all_global_earned
    earned_badges = []
    Badge.find_each do |badge|
      user_is_correct = badge.user_id == @token.user_id.to_i
      badge_is_global = badge.badge_def.global == true
      earned_badges << badge.badge_def if (user_is_correct && badge_is_global)
    end
    earned_badges
  end
  
  def find_all_global_badges
    all_badges = []
    BadgeDef.find_each do |bdef|
      badge_is_global = bdef.global == true
      all_badges << bdef if (badge_is_global)
    end
    all_badges
  end
  
end
