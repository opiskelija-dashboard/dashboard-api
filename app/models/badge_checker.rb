# Lists all available badge criteria as functions.
# config/badges.yml uses these.
# Also offers a function to check which badges a user (user_id) is worthy of.
class BadgeChecker

  # This is only temporary because we have an old model of CP.
  def user_has_one_point(id)
    CumulativePoint.new(Token.new).user_points[0].count >= 20
  end

  def user_is_cool(id)
    true if id == 2
  end

  def lol(id)
    true if id == 3
  end

  # Checks which badges a user (user_id) is worthy of.
  def check(id)
    badge_info = {}
    Rails.configuration.badges.each do |badge|
      badge_info[badge["badge"]["name"]] = true
      badge["badge"]["criteria"].each do |criteria|
        if !(BadgeChecker.new.send(criteria, id))
          badge_info[badge["badge"]["name"]] = false
        end
      end
    end
    badge_info
  end

end