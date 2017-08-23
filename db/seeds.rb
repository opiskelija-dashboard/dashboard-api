# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])

#   Character.create(name: 'Luke', movie: movies.first)

BadgeCode.create(
  [
    { id: 1, name: 'Always true', description: 'What it says on the tin',
      code: 'return true', created_by: 1, modified_by: 1, bugs: 0,
      course_points_only: 0, created_at: Time.at(1), updated_at: Time.at(1) },
    { id: 2, name: 'Always false', description: 'What it says on the tin',
      code: 'return false', created_by: 1, modified_by: 1, bugs: 0,
      course_points_only: 0, created_at: Time.at(1), updated_at: Time.at(1) }
  ]
)

BadgeDef.create(
  id: 1, name: 'Achi 1 (always true)', created_at: Time.at(1),
  updated_at: Time.at(1), active: true, course_specific: false, global: true
)
BadgeDef.create(
  id: 2, name: 'Achi 2 (always false)', created_at: Time.at(1),
  updated_at: Time.at(1), active: true, course_specific: false, global: true
)

# Link the two BadgeCodes to our two BadgeDefs thusly:
# BadgeDef 'Achi 1 (always true)' --- BadgeCode 1, 'Always true'
# BadgeDef 'Achi 2 (always false)' --- BadgeCode 1, 'Always true'
# AND                              --- BadgeCode 2, 'Always false'
linked_already = BadgeDef.find(1).badge_codes.exists?(BadgeCode.find(1))
BadgeDef.find(1).badge_codes << BadgeCode.find(1) unless linked_already

linked_already = BadgeDef.find(2).badge_codes.exists?(BadgeCode.find(1))
BadgeDef.find(2).badge_codes << BadgeCode.find(1) unless linked_already

linked_already = BadgeDef.find(2).badge_codes.exists?(BadgeCode.find(2))
BadgeDef.find(2).badge_codes << BadgeCode.find(2) unless linked_already
