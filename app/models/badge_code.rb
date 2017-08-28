class BadgeCode < ApplicationRecord
  has_and_belongs_to_many :badge_defs, -> { distinct }

  # BadgeCode fields:
  # id
  # name
  # description
  # code
  # created_by
  # modified_by
  # bugs
  # course_points_only
  # created_at
  # updated_at
  # badge_defs   --virtual field, returns array of BadgeDefs

  def appropriate_binding(user_id, course_points, all_points)
    if self.course_points_only?
      course_specific_binding(user_id, course_points)
    else
      global_binding(user_id, all_points)
    end
  end

  def global_binding(user_id, all_points)
    binding
  end

  def course_specific_binding(user_id, course_points)
    binding
  end
end
