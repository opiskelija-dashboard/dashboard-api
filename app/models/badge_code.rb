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
  # course_points
  # user_points
  # exercises
  # created_at
  # updated_at
  # badge_defs   --virtual field, returns array of BadgeDefs

  # Checks which data to give to the binding and then returns the binding
  def appropriate_binding(user_id, course_points, user_points, exercises)
    data = {}
    data[:user_points] = user_points if self.user_points?
    data[:course_points] = course_points if self.course_points?
    data[:exercises] = exercises if self.exercises?
    badgecode_binding(user_id, data)
  end

  # Creates the binding for testing the badge_codes
  def badgecode_binding(user_id, data)
    binding
  end
end
