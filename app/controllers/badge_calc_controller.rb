class BadgeCalcController < ApplicationController

  def initialize
    rcpsc = Rails.configuration.points_store_class
    @point_source = rcpsc == 'MockPointsStore' ? MockPointsStore : PointsStore
  end

  # GET /calc-user-badges/course/:course_id
  # Return hash:
  # {to_award: [array of badgedef objects], errors: [errors ready to render]}
  def calc_user
    course_id = params[:course_id].to_s
    course_points = @point_source.course_points_update_if_necessary(course_id, @token)
    user_points = course_points.find_all { |cp| cp['awarded_point']['user_id'] == @token.user_id }
    exercise_stuff = ExerciseFetcher.fetch_exercises(course_id, @token)
    if !exercise_stuff[:success]
      render json: { errors: exercise_stuff[:errors] },
             status: 500 # internal server error
      return false
    else
      exercises = exercise_stuff[:data]
    end
    user_id = @token.user_id
    badgedefs = find_badgedefs_to_test(user_id, course_id)
    h = test_loop(badgedefs, user_id, course_points, user_points, exercises)
    if h[:errors].empty?
      # Here, we'd create Badge objects and save them.
      save_badges(user_id, h[:to_award])
      # TODO: error checking from save_badges
      render json: { data: h[:to_award] }, status: 200 # ok
    else
      render json: { errors: h[:errors] }, status: 500 # internal server error
    end
  end

  private

  # Loop that tests whether to give the user_id badges or not
  def test_loop(badgedefs, user_id, course_points, user_points, exercises)
    to_award = []
    errors = []
    badgedefs.each do |badgedef|
      Rails.logger.debug("Evaluating BadgeDef #{badgedef.id}, user #{user_id}")
      rezult = BadgeHelper.evaluate_badgedef(badgedef, user_id, course_points,
                                             user_points, exercises)
      if rezult[:ok]
        to_award.push(badgedef) if rezult[:give_badge]
      else
        # This clunky line has to be used because
        # [a, b, c].push([x, y, z]) doesn't give [a, b, c, x, y, z]
        # but rather [a, b, c, [x, y, z]].
        rezult[:errors].each { |e| errors.push(e) }
      end
    end
    { to_award: to_award, errors: errors }
  end

  # Finds badges the given user doesn't already have in the given course
  def find_badgedefs_to_test(user_id, course_id)
    user_badges = Badge.where(user_id: user_id)
    awarded_bd_ids = user_badges.map { |b| b.badge_def_id }

    all_course_badgedefs = BadgeDef.where(course_id: course_id, active: true)
    all_bd_ids = all_course_badgedefs.map { |bd| bd.id }
    unawarded_bd_ids = all_bd_ids - awarded_bd_ids

    BadgeDef.find(unawarded_bd_ids)
  end

  # Saves the given badge_defs to the user_id as badges
  def save_badges(user_id, badge_defs)
    badge_defs.each do |bdef|
      Badge.new do |badge|
        badge.user_id = user_id
        badge.badge_def_id = bdef.id
        badge.save
      end
    end
  end
end
