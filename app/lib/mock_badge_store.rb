class MockBadgeStore
  
  def self.get_badge_definitions
    @badges_defs
  end
  
  def self.get_badge_criteria
    @badge_crits
  end

  def self.get_awarded_badges_with_user_id(user_id)
    awbadges = get_awarded_badges
    awbadges_with_user_id = []
    awbadges.each do |ab|
      awbadges_with_user_id << ab if (ab["user_id"] == user_id)
    end
    awbadges_with_user_id
  end

  def self.get_awarded_badges
    @awarded_badges
  end

  
  def self.update_awarded_badges(course_id, token)
    bchecker = BadgeChecker.new(course_id, token)
    badges = get_badges_with_course_id(course_id, true)
    badges_to_be_awarded = bchecker.check(badges)
    badges_to_be_awarded.each do |user_badges|
      string = "User " + user_badges[0].to_s + " was awarded the following badges "
      user_badges[1].each do |badge|
        string += badge["name"] + ", "
      end
      string = string[0...-2]
      string += "."
      puts string
    end
    return nil
  end
  
  # Returns a hash where the course_id is the same as in parameters:
  # { badge_definition: [badge_criteria]}
  def self.get_badges_with_course_id(course_id, active_only)
    badge_defs = get_badge_definitions
    badge_crits = get_badge_criteria
    badges_with_course_id = {}
    badge_defs.each do |bdef|
      badges_with_course_id[bdef] = []
      badge_crits.each do |bcrit|
        name_is_same = bdef["name"] == bcrit["name"]
        course_id_is_right = bdef["course_id"] == course_id
        badge_is_active = bdef["active"]
        if (name_is_same && course_id_is_right && badge_is_active) || (name_is_same && course_id_is_right && !active_only)
          badges_with_course_id[bdef] << bcrit
        end
      end
    end
    
    badges_with_course_id
  end
  
  # Returns a hash:
  # { badge_definition: [badge_criteria]}
  def self.get_all_badges(active_only)
    badge_defs = get_badge_definitions
    badge_crits = get_badge_criteria
    badges = {}
    badge_defs.each do |bdef|
      badges[bdef] = [] 
      badge_crits.each do |bcrit|
        name_is_same = bdef["name"] == bcrit["name"]
        badge_is_active = bdef["active"]
        if (name_is_same && badge_is_active) || (name_is_same && !active_only)
          badges[bdef] << bcrit
        end
      end
    end
    
    badges
  end
  
  @badges_defs = [
  { "name" => "test1",
  "iconref" => "preschool.jpg",
  "flavor_text" => "could do this blindfolded",
    "created_at" => "2016-10-17T11:10:17.295+03:00",
    "updated_at" => "2016-10-17T11:10:17.295+03:00",
    "created_by" => 1,
    "updated_by" => 1,
    "active" => true,
    "course_specific" => false,
    "global" => true,
    "course_id" => 1
  },
  { "name" => "test2",
  "iconref" => "impossibru.jpg",
  "flavor_text" => "couldn't do this",
    "created_at" => "2016-10-17T11:10:17.295+03:00",
    "updated_at" => "2016-10-17T11:10:17.295+03:00",
    "created_by" => 1,
    "updated_by" => 1,
    "active" => false,
    "course_specific" => false,
    "global" => true,
    "course_id" => 1
    }]
    
    
    @badge_crits = [
    { "name" => "test1",
    "description" => "easy get",
    "code" => "2 > 1",
    "created_at" => "2016-10-17T11:10:17.295+03:00",
    "updated_at" => "2016-10-17T11:10:17.295+03:00",
    "created_by" => 1,
    "updated_by" => 1,
    "bugs" => false,
    "course_points_only" => false
  },
  { "name" => "test2",
  "description" => "never get",
  "code" => %q(2 == 2),
  "created_at" => "2016-10-17T11:10:17.295+03:00",
  "updated_at" => "2016-10-17T11:10:17.295+03:00",
  "created_by" => 1,
  "updated_by" => 1,
  "bugs" => false,
  "course_points_only" => false 
  }]
  
  @awarded_badges = [
  { "badge_definition_id" => 1,
  "name" => "test1",
  "user_id" => 1,
  "course_id" => 1,
  "created_at" => "2016-10-17T11:10:17.295+03:00",
  "updated_at" => "2016-10-17T11:10:17.295+03:00"
  },{ "badge_definition_id" => 2,
  "name" => "test2",
  "user_id" => 1,
  "course_id" => 1,
  "created_at" => "2016-10-17T11:10:17.295+03:00",
  "updated_at" => "2016-10-17T11:10:17.295+03:00"
  }]
  
end