class BadgesController < ApplicationController
  # GET /user-badges/course/:course_id/earned
  def earned_in_course
    course_id = params['course_id'].to_i
    earned_badges = find_earned_in_course(course_id, true)
    earned_badges_info = format_earned_for_output(earned_badges)
    render json: { 'data' => earned_badges_info }
  end

  # GET /user-badges/course/:course_id/unearned
  def unearned_in_course
    course_id = params['course_id'].to_i
    earned_in_course = find_earned_in_course(course_id, false)
    all_badges_in_course = find_all_in_course(course_id)
    unearned_in_course = all_badges_in_course - earned_in_course
    unearned_in_course_info = format_unearened_for_output(unearned_in_course)
    render json: { 'data' => unearned_in_course_info }
  end

  private

  # Returns badges user has done in given course
  def find_earned_in_course(course_id, badges_instead_of_badge_defs)
    earned_in_course = []
    Badge.find_each do |badge|
      course_is_right = badge.badge_def.course_id == course_id
      user_is_right = badge.user_id == @token.user_id.to_i
      if course_is_right && user_is_right
        earned_in_course << if badges_instead_of_badge_defs
                              badge
                            else
                              badge.badge_def
                            end
      end
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

  # Formats given badges to not include all info
  def format_earned_for_output(earned_badges)
    earned_badges_info = []
    unless earned_badges.nil?
      earned_badges.each do |badge|
        earned_badge_info = {}
        earned_badge_info['badgedef_id'] = badge.badge_def.id
        earned_badge_info['name'] = badge.badge_def.name
        earned_badge_info['iconref'] = badge.badge_def.iconref
        earned_badge_info['flavor_text'] = badge.badge_def.flavor_text
        earned_badge_info['awarded_at'] = badge.created_at
        earned_badges_info << earned_badge_info
      end
    end
    earned_badges_info
  end

  # formats given badge_defs to not include all info
  def format_unearened_for_output(badge_defs)
    unearned_badges_info = []
    unless badge_defs.nil?
      badge_defs.each do |badgedef|
        unearned_badge_info = {}
        unearned_badge_info['badgedef_id'] = badgedef.id
        unearned_badge_info['name'] = badgedef.name
        unearned_badge_info['flavor_text'] = badgedef.flavor_text
        unearned_badge_info['iconref'] = badgedef.iconref
        unearned_badges_info << unearned_badge_info
      end
    end
    unearned_badges_info
  end
end
