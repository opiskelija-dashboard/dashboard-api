class BadgeCalcController < ApplicationController

  def initialize
    rcpsc = Rails.configuration.points_store_class
    @point_source = rcpsc == 'MockPointsStore' ? MockPointsStore : PointsStore
  end

  # GET /calc-user-badges/course/:course_id
  # Return hash:
  # {to_award: [array of badgedef ids], errors: [errors ready to render]}
  def calc_user
    course_id = params[:course_id].to_s
    course_points = course_points_update_if_necessary(course_id)
    user_id = @token.user_id
    badgedefs = find_course_specific_badgedefs_to_test(user_id, course_id)
    h = test_loop(badgedefs, user_id, course_points)
    if h[:errors].empty?
      # Here, we'd create Badge objects and save them.
      save_badges(user_id, h[:to_award])
      render json: { data: h[:to_award] }, status: 200 # ok
    else
      render json: { errors: h[:errors] }, status: 500 # internal server error
    end
  end

  # GET /calc-user-badges/global
  # Return hash:
  # {to_award: [array of badgedef ids], errors: [errors ready to render]}
  def calc_global
    toutes_les_points = @point_source.all_points
    user_id = @token.user_id
    badgedefs = find_global_badgedefs_to_test(user_id)
    h = test_loop(badgedefs, user_id, toutes_les_points)
    if h[:errors].empty?
      # Here, we'd create Badge objects and save them.
      save_badges(user_id, h[:to_award])
      render json: { data: h[:to_award] }, status: 200 # ok
    else
      render json: { errors: h[:errors] }, status: 500 # internal server error
    end
  end

  private

  def test_loop(badgedefs, user_id, points)
    to_award = []
    errors = []
    badgedefs.each do |badgedef|
      Rails.logger.debug("Evaluating BadgeDef #{badgedef.id}, user #{user_id}")
      rezult = BadgeHelper.evaluate_badgedef(badgedef, user_id, points)
      if rezult[:ok]
        to_award.push(badgedef.id) if rezult[:give_badge]
      else
        # This clunky method has to be used because
        # [a, b, c].push([x, y, z]) doesn't give [a, b, c, x, y, z]
        # but rather [a, b, c, [x, y, z]].
        rezult[:errors].each { |e| errors.push(e) }
      end
    end
    { to_award: to_award, errors: errors }
  end

  def find_course_specific_badgedefs_to_test(user_id, course_id)
    user_badges = Badge.where(user_id: user_id)
    awarded_bd_ids = user_badges.map { |b| b.badge_def_id }

    all_course_badgedefs = BadgeDef.where(course_specific: true,
                                          course_id: course_id,
                                          active: true)
    all_bd_ids = all_course_badgedefs.map { |bd| bd.id }
    unawarded_bd_ids = all_bd_ids - awarded_bd_ids

    unawarded_course_badgedefs = BadgeDef.find(unawarded_bd_ids)
  end

  def find_global_badgedefs_to_test(user_id)
    user_badges = Badge.where(user_id: user_id)
    awarded_bd_ids = user_badges.map { |b| b.badge_def_id }

    all_badgedef_ids = BadgeDef.where(global: true,
                                      active: true).map { |bd| bd.id }
    unawarded_bd_ids = all_badgedef_ids - awarded_bd_ids

    unawarded_badgedefs = BadgeDef.find(unawarded_bd_ids)
  end

  # TODO: move this to (Mock)PointsStore
  def course_points_update_if_necessary(course_id)
    no_points = !@point_source.has_course_points?(course_id)
    stale_points = @point_source.course_point_update_needed?(course_id)
    if no_points || stale_points
      @point_source.update_course_points(course_id, @token)
    end
    @point_source.course_points(course_id)
  end

  def save_badges(user_id, badge_def_ids)
    badge_def_ids.each do |bdid|
      Badge.new do |badge|
        badge.user_id = user_id
        badge.badge_def_id = bdid
        badge.save
      end
    end
  end

end
