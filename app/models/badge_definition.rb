class BadgeDefinition < ApplicationRecord

  has_many :course_badges, dependent: :destroy
  has_many :awarded_badges, dependent: :destroy

end
