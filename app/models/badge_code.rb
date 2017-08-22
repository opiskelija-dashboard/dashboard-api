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

end
