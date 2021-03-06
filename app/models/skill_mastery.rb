# NOTE!
# This class uses fake definitions to create shown data.

# Makes skill mastery data for current user and all users
# by statement labels ('for', 'while', 'if', ...).
# Compares PointsStore's points and MockSkillMasteryData (in app/lib).
class SkillMastery
  def initialize(course_id, token)
    @course_id = course_id
    @token = token
    # Typically, point_source would be PointsStore, but for testing purposes
    # you might want to use MockPointsStore.
    config = Rails.configuration.points_store_class
    @point_source = config == 'MockPointsStore' ? MockPointsStore : PointsStore
    @point_source.course_points_update_if_necessary(@course_id, @token)
  end

  # Combines current_user_skill_mastery and all_skill_mastery.
  # Returns an array of hashes like: {label: 'for', user: 30, all: 50}
  def combined_skill_mastery
    combined = []
    user = current_user_skill_mastery
    all = all_skill_mastery
    statement_labels = user.keys
    statement_labels.each do |label|
      combined << { label: label, user: user[label], all: all[label] }
    end
    combined
  end

  # Calculates current users skill mastery percentages (points awarded by
  # certain categories/statement labels).
  # Returns a hash like: {'for': 30, 'while':40, if: '5'}
  def current_user_skill_mastery
    raw_points = PointsHelper.users_own_points(@point_source,
                                               @course_id,
                                               @token.user_id)
    users_points_by_name = []
    raw_points.each do |raw_point|
      users_points_by_name << raw_point['awarded_point']['name']
    end

    points_by_statement = {}
    fake_tmc_parsed_json = MockSkillMasteryData.fake_data
    fake_tmc_parsed_json.each do |statement, fake_points|
      intersetion = fake_points & users_points_by_name
      procentage = ((intersetion.size.to_f / fake_points.size) * 100).round(0)
      points_by_statement[statement] = procentage
    end
    points_by_statement
  end

  # Calculates all users' skill mastery percentages (points awarded by certain
  # categories/statement labels).
  # Returns a hash like: {'for': 30, 'while':40, if: '5'}
  def all_skill_mastery
    raw_points = PointsHelper.all_course_points(@point_source, @course_id)
    points_by_name = []
    users = {}
    raw_points.each do |raw_point|
      points_by_name << raw_point['awarded_point']['name']
      users[raw_point['awarded_point']['user_id']] = 0
    end

    counts = Hash.new(0)
    points_by_name.each { |point_name| counts[point_name] += 1 }

    points_by_statement = Hash.new(0)
    p_b_s = points_by_statement
    fake_tmc_parsed_json = MockSkillMasteryData.fake_data
    fake_tmc_parsed_json.each do |statement, fake_points|
      fake_points.each do |fake_point_name|
        if counts[fake_point_name] > 0
          p_b_s[statement] += counts[fake_point_name]
        end
      end
      p_b_s[statement] /= users.size.to_f
      p_b_s[statement] /= fake_points.size
      p_b_s[statement] = (p_b_s[statement] * 100).round(0)
    end
    p_b_s
  end
end
