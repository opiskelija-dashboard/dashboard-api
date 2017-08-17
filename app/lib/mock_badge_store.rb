class MockBadgeStore
  
  def self.save(something)
    #nothing here
  end
  
  def self.update(something)
    #nothing here either
  end
  
  def self.get_all_badges
    return @badges
  end
  
  def self.get_course_badges
    return @course_badges
  end
  
  def self.get_badges_with_course_id(course_id)
    all_badges = get_all_badges
    course_badges = get_course_badges
    badges_with_course_id = []
    course_badges.each do |course_badge|
      all_badges.each do |raw_badge|
        if course_badge["badge_name"] == raw_badge["name"] && course_badge["course_id"] == course_id
          badges_with_course_id << raw_badge   
        end
      end
    end
    badges_with_course_id
  end
  

  @badges = [
  { "name" => "test2",
  "criteria" => 
  %q(
  found = false
  all_points.each do |raw_point|
    found = true if (raw_point["awarded_point"]["user_id"] == user_id[0]);
  end
  found
  ),
  "created_at" => "2016-10-17T11:10:17.295+03:00",
  "modified_at" => "2016-10-17T11:10:17.295+03:00",
  "global" => false,
  "course_specific" => true,
  "active" => true
  },
  { "name" => "freepoint",
  "criteria" => 
  %q(
  free = true
  ),
  "created_at" => "2016-10-17T11:10:17.295+03:00",
  "modified_at" => "2016-10-17T11:10:17.295+03:00",
  "global" => false,
  "course_specific" => true,
  "active" => true
  }]
  
  
  @course_badges = [
  { "badge_name" => "test2",
  "course_id" => 214
  },{ "badge_name" => "freepoint",
  "course_id" => 215
  }]

end