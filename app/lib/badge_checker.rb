# Checks which badges a user is worthy of and awards badges to them.
class BadgeChecker

  def initialize(course_id, token)
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore
    @course_id = course_id
    @token = token

    if (!@point_source.has_course_points?(@course_id))
      Rails.logger.debug("PointsStore didn't have points of course " + @course_id.to_s + ", fetching...");
      @point_source.update_course_points(@course_id, token)
    end
  end

  # Runs the Eval'd code in a environment.
  def achievement_predication_environment(user_id, all_points)
    return binding()
  end

  # Checks which badges a user (user_id) is worthy of. 
  def check(badges)
    points = @point_source.course_points(@course_id)
    user_ids = PointsHelper.user_ids_in_points(points)
    badges_to_be_awarded = {}
    user_ids.each do |user_id|
      badges_for_user = []
      badges.each do |badge|
        award_badge = true
        badge[1].each do |badge_criterion|
          binding = achievement_predication_environment(user_id, points)
          criterion_passes = eval(badge_criterion["code"], binding);
          award_badge = false if !criterion_passes
        end
        if award_badge
          badges_for_user << badge[0]
        end
      end
      badges_to_be_awarded[user_id] = badges_for_user  
    end
    badges_to_be_awarded
  end

end
