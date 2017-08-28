class Badge < ApplicationRecord
  belongs_to :badge_def

  # Badge fields:
  # id
  # badge_def_id
  # user_id
  # course_id
  # created_at          
  # updated_at 
end
