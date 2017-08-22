class BadgeDef < ApplicationRecord
  has_many :badges
  has_and_belongs_to_many :badge_codes
end
