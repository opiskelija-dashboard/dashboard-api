# Lists all available badge criteria as functions.
# config/badges.yml uses these.
# Also offers a function to check which badges a user (user_id) is worthy of.
class BadgeChecker

  # This is only temporary because we have an old model of CP.
  #def user_has_one_point(id)
  #  CumulativePoint.new(Token.new).user_points[0].count >= 20
  #end

  #def user_is_cool(id)
  #  true if id == 2
  #end

  #def lol(id)
  #  true if id == 3
  #end
  def initialize(course_id, token)
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore
    @badges = Rails.configuration.badge_class == "MockBadges" ? MockBadges : Badges
    @course_id = course_id
    @token = token

    if (!@point_source.has_course_points?(@course_id))
      Rails.logger.debug("PointsStore didn't have points of course " + @course_id.to_s + ", fetching...");
      @point_source.update_course_points(@course_id, token)
    end
  end

  def achievement_predication_environment(user_id, all_points)
    return binding()
  end

  #returns a hash of unique user_ids in points
  def get_user_ids(all_points)
    user_ids = []
    all_points.each do |point|
      user_ids << [point["awarded_point"]["user_id"]]
    end
    return user_ids.uniq
  end

  # Checks which badges a user (user_id) is worthy of.
  def check()
    badges = get_badges
    points = @point_source.course_points(@course_id)
    user_ids = get_user_ids(points)
    user_ids.each do |user_id|
      badges.each do |badge_definition|
        binding = achievement_predication_environment(user_id, points)
        
        got_achievement = eval(badge_definition["criteria"], binding);
        if (got_achievement)
        # save to database here
        puts ("User " + user_id.to_s + " got achievement '" + badge_definition["name"] + "'");
        end
      end  
    end
    return nil
  end

  def get_badges
    #get badges here
    @badges.all
  end
end
