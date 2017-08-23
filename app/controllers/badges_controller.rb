class BadgesController < ApplicationController
  
  # GET /user-badges/course/:course_id/earned
  def get_earned_in_course
    get_user_id
    course_id = params["course_id"].to_i
    earned_badges = find_earned_in_course(course_id)
    render json: {"data" => earned_badges }
  end
  
  # GET /user-badges/course/:course_id/unearned
  def get_unearned_in_course
    get_user_id
    course_id = params["course_id"].to_i  
    earned_in_course = find_earned_in_course(course_id)
    all_badges_in_course = find_all_in_course(course_id)
    unearned_in_course = all_badges_in_course - earned_in_course
    render json: {"data" => unearned_in_course}
  end
  
  # GET /user-badges/global/earned
  def get_earned_global
    get_user_id
    earned_badges = find_all_earned
    render json: {"data" => earned_badges}
  end
  
  # GET /user-badges/global/unearned
  def get_unearned_global
    get_user_id
    all_badges = find_all_badges
    earned_badges = find_all_earned
    unearned = all_badges - earned_badges
    render json: {"data" => unearned}
  end
  
  def get_user_id
    @user_id = @token.user_id.to_s
  end
  
  # Returns badges user has done in given course
  def find_earned_in_course(course_id)
    earned_in_course = []
    Badge.find_each do |badge|
      course_is_right = badge.course_id == course_id
      user_is_right = badge.user_id == @user_id
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
  
  def find_all_earned
    earned_badges = []
    Badge.find_each do |badge|
      earned_badges << badge.badge_def if (badge.user_id == @user_id)
    end
    earned_badges
  end
  
  def find_all_badges
    all_badges = []
    BadgeDef.find_each do |bdef|
      all_badges << bdef
    end
    all_badges
  end
  
  def get_user_id
    @user_id
  end
  
end
