class BadgeDef < ApplicationRecord
  has_many :badges
  has_and_belongs_to_many :badge_codes, -> { distinct }

  # BadgeDef.find(2).badge_codes << BadgeCode.find(1) unless BadgeDef.find(2).badge_codes.exists?(BadgeCode.find(1).id)
  # BadgeDef fields:
  # id
  # name
  # iconref
  # created_at
  # updated_at
  # flavor_text
  # made_by
  # active
  # course_specific
  # global
  # course_id
  # badge_codes   --virtual field, return array of BadgeCodes
end
