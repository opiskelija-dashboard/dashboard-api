class BadgeStore
  
  # Returns either only active badge definitions with given course_id, or all
  # badge definitions with given course_id 
  def self.get_badges_with_course_id(course_id, active_only)
    badges_with_course_id = []
    
    CourseBadge.find_each do |course_badge|
      badge_def = course_badge.badge_definition
      badge_is_active = badge_def.active
      if (active_only && badge_is_active) || !active_only
        badges_with_course_id << badge_def
      end
    end
    badges_with_course_id
  end
  

  #Returns either all badges, or only those with active attribute true.
  def self.get_all_badges(active_only)
    badges_with_course_id = []
    
    BadgeDefinition.find_each do |badge_def|
      badge_is_active = badge_def.active
      if (active_only && badge_is_active) || !active_only
        badges_with_course_id << badge_def
      end
    end
    badges_with_course_id
  end
  
end