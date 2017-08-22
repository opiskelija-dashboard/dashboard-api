class BadgeCode < ApplicationRecord
  has_and_belongs_to_many :badge_defs
end
