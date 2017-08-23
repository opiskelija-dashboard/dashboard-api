class BadgesController < ApplicationController
  # GET /user-badges/course/:course_id/earned
  def earned_in_course
    course_id = params['course_id'].to_i
    earned_badges = find_earned_in_course(course_id)
    earned_badges_info = parse_earned(earned_badges)
    render json: { 'data' => earned_badges_info }
  end

  # GET /user-badges/course/:course_id/unearned
  def unearned_in_course
    course_id = params['course_id'].to_i
    earned_in_course = find_earned_in_course(course_id)
    all_badges_in_course = find_all_in_course(course_id)
    unearned_in_course = all_badges_in_course - earned_in_course
    unearned_in_course_info = parse_unearned(unearned_in_course)
    render json: { 'data' => unearned_in_course_info }
  end

  # GET /user-badges/global/earned
  def earned_global
    # The following method returns badges with true and badge_defs with false.
    earned_badges = find_all_global_earned(true)
    earned_badges_info = parse_earned(earned_badges)
    render json: { 'data' => earned_badges_info }
  end

  # GET /user-badges/global/unearned
  def unearned_global
    all_global_badges = find_all_global_badges
    # The following method returns badge_defs with false and badges with true.
    earned_badges = find_all_global_earned(false)
    unearned_badges = all_global_badges - earned_badges
    unearned_badges_info = parse_unearned(unearned_badges)
    render json: { 'data' => unearned_badges_info }
  end

  # Returns badges user has done in given course
  def find_earned_in_course(course_id)
    earned_in_course = []
    Badge.find_each do |badge|
      course_is_right = badge.course_id == course_id
      user_is_right = badge.user_id == @token.user_id.to_i
      earned_in_course << badge if course_is_right && user_is_right
    end
    earned_in_course
  end

  # Returns all possible badges in given course
  def find_all_in_course(course_id)
    all_badges_in_course = []
    BadgeDef.find_each do |bdef|
      badge_is_active = bdef.active
      course_id_is_right = course_id == bdef.course_id
      all_badges_in_course << bdef if badge_is_active && course_id_is_right
    end
    all_badges_in_course
  end

  # Returns all global badges user has earned
  # If you give true as a parameter, this method returns badges.
  # If you give false, this returns badge_defs.
  def find_all_global_earned(badges_instead_of_badge_defs)
    earned_badges = []
    Badge.find_each do |badge|
      user_is_correct = badge.user_id == @token.user_id.to_i
      badge_is_global = badge.badge_def.global == true
      if user_is_correct && badge_is_global
        earned_badges << if badges_instead_of_badge_defs
                           badge
                         else
                           badge.badge_def
                         end
      end
      earned_badges
    end
  end

  # Returns all global badges that are active
  def find_all_global_badges
    all_badges = []
    BadgeDef.find_each do |bdef|
      badge_is_active = bdef.active
      badge_is_global = bdef.global == true
      all_badges << bdef if badge_is_global && badge_is_active
    end
    all_badges
  end

  # Parses given badges to not include irrelevant info
  def parse_earned(earned_badges)
    earned_badges_info = {}
    unless earned_badges.empty?
      earned_badges.each do |badge|
        earned_badges_info['name'] = badge.badge_def.name
        earned_badges_info['iconref'] = badge.badge_def.iconref
        earned_badges_info['flavor_text'] = badge.badge_def.flavor_text
        earned_badges_info['awarded_at'] = badge.created_at
      end
    end
    earned_badges_info
  end

  # Parses given badge_defs to not include irrelevant info
  def parse_unearned(unearned_in_course)
    unearned_in_course_info = {}
    unearned_in_course.each do |badgedef|
      unearned_in_course_info['name'] = badgedef.name
      unearned_in_course_info['flavor_text'] = badgedef.flavor_text
      unearned_in_course_info['iconref'] = badgedef.iconref
    end
    unearned_in_course_info
  end
end
