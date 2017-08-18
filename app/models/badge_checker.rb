# Checks which badges a user is worthy of and awards badges to them.
class BadgeChecker

  def initialize(course_id, token)
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore
    @badges = Rails.configuration.badge_store_class == "MockBadgeStore" ? MockBadgeStore : BadgeStore
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
  def check(active_only)
    badges = @badges.get_badges_with_course_id(@course_id, active_only)
    points = @point_source.course_points(@course_id)
    user_ids = PointsHelper.user_ids_in_points(points)
    user_ids.each do |user_id|
      badges.each do |badge_definition|
        binding = achievement_predication_environment(user_id, points)
        got_achievement = eval(badge_definition["criteria"], binding);
        if (got_achievement)
        # save to database here 
        # Something along the lines of
        # AwardedBadge.save(badge_definition["id"], user_id, @course_id)
        puts ("User " + user_id.to_s + " got achievement '" + badge_definition["name"] + "'");
        end
      end  
    end
    return nil
  end

end
