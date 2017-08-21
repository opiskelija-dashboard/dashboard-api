class BadgeDefinition < ApplicationRecord
  has_many :awarded_badges
  has_and_belongs_to_many :badge_criteria
end
