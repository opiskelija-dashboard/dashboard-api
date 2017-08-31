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
      code: 'true', created_by: 1, modified_by: 1, active: true,
      course_points: false, user_points: true, exercises: false,
      created_at: Time.at(1), updated_at: Time.at(1) },
    { id: 2, name: 'Always false', description: 'What it says on the tin',
      code: 'false', created_by: 1, modified_by: 1, active: true,
      course_points: false, user_points: true, exercises: false,
      created_at: Time.at(1), updated_at: Time.at(1) }
  ]
)
BadgeCode.create(
  id: 3, name: 'Tee 1 tehtävä', created_by: 0, modified_by: 0, active: true,
  course_points: false, user_points: true, exercises: false,
  created_at: Time.at(1), updated_at: Time.at(1), code:
  "
  data[:user_points].size >= 1
  "
)
BadgeCode.create(
  id: 4, name: 'Tee 100 tehtävää', created_by: 0, modified_by: 0, active: true,
  course_points: false, user_points: true, exercises: false,
  created_at: Time.at(1), updated_at: Time.at(1), code:
  "
  data[:user_points].size >= 100
  "
)
BadgeCode.create(
  id: 5, name: '5:nä peräkkäisenä päivänä 3 tehtävää', created_by: 0,
  modified_by: 0, active: true, course_points: false, user_points: true,
  exercises: false, created_at: Time.at(1), updated_at: Time.at(1), code:
  "
  points_in_order = data[:user_points].sort_by{|p| p['awarded_point']['created_at']}
  result = false
  reset = false
  count = 0
  days = 0
  unless points_in_order.empty?
    date = points_in_order.first['awarded_point']['created_at'].to_date
    points_in_order.each do |point|
      if date == point['awarded_point']['created_at'].to_date
        count += 1
        reset = false
      else
        count = 1
        dayskip = point['awarded_point']['created_at'].to_date - 1 != date
        days = 0 if reset || dayskip
        reset = true
        date = point['awarded_point']['created_at'].to_date
      end
      days +=1 if count == 3
      if days == 5
        result = true
        break
      end
    end
  end
  result
  "
)
BadgeCode.create(
  id: 6, name: 'Tee 50 tehtävää', created_by: 0, modified_by: 0, active: true,
  course_points: false, user_points: true, exercises: false,
  created_at: Time.at(1), updated_at: Time.at(1), code:
  "
  data[:user_points].size >= 50
  "
)
BadgeCode.create(
  id: 7, name: 'Tee ekan viikon kaikki tehtävät', created_by: 0, modified_by: 0,
  active: true, course_points: false, user_points: true, exercises: true,
  created_at: Time.at(1), updated_at: Time.at(1), code:
  "
  ordered_exercises = data[:exercises].sort_by{|e| e['deadline']}
  first_week_points = 0
  first_week = ordered_exercises.first['deadline'].to_date.strftime('%G-%V')

  ordered_exercises.each do |exer|
    week = exer['deadline'].to_date.strftime('%G-%V')
    if week == first_week
      exer['available_points'].each do |apoint|
        first_week_points += 1
      end
    end
  end

  all_done = false
  user_points_first_week = 0
  data[:user_points].each do |p|
    week_point_was_awarded = p['awarded_point']['created_at'].to_date.strftime('%G-%V')
    user_points_first_week += 1 if first_week == week_point_was_awarded
  end
  byebug

  all_done = true if first_week_points == user_points_first_week
  all_done
  "
)

BadgeDef.create(
  id: 1, name: 'Achi 1 (always true)', created_at: Time.at(1),
  updated_at: Time.at(1), active: true, course_id: 1
)
BadgeDef.create(
  id: 2, name: 'Achi 2 (always false)', created_at: Time.at(1),
  updated_at: Time.at(1), active: true, course_id: 1
)
BadgeDef.create(
  id: 3, name: 'Achi 3 (inactive)', created_at: Time.at(1),
  updated_at: Time.at(1), active: false, course_id: 1
)
BadgeDef.create(
  id: 4, name: 'Cherry Popper', flavor_text: 'Tee 1 tehtävä',
  created_at: Time.at(1), updated_at: Time.at(1), active: true, course_id: 214
)
BadgeDef.create(
  id: 5, name: 'Centurion', flavor_text: 'Tee 100 tehtävää',
  created_at: Time.at(1), updated_at: Time.at(1), active: true, course_id: 214
)
BadgeDef.create(
  id: 6, name: 'Tasainen raataja',
  flavor_text: 'Tee 5:nä peräkkäisenä päivänä 3 tai enemmän tehtävää.',
  created_at: Time.at(1), updated_at: Time.at(1), active: true, course_id: 214
)
BadgeDef.create(
  id: 7, name: 'Candy Shop', flavor_text: 'Tee 50 tehtävää',
  created_at: Time.at(1), updated_at: Time.at(1), active: true, course_id: 214
)
BadgeDef.create(
  id: 8, name: 'Rakettilähtö',
  flavor_text: 'Tee ensimmäisen viikon kaikki tehtävät', created_at: Time.at(1),
  updated_at: Time.at(1), active: true, course_id: 214
)

# Link the two BadgeCodes to our two BadgeDefs thusly:
# BadgeDef 'Achi 1 (always true)' --- BadgeCode 1, 'Always true'
# BadgeDef 'Achi 2 (always false)' --- BadgeCode 1, 'Always true'
# AND                              --- BadgeCode 2, 'Always false'
# BadgeDef 'Achi 3 (inactive)' --- BadgeCode 1, 'Always true'
# BadgeDef 'Cherry Popper' --- BadgeCode 3, 'Tee 1 tehtävä'
# BadgeDef 'Centurion' --- BadgeCode 4, 'Tee 100 tehtävää'
# BadgeDef 'Tasainen raataja' --- BadgeCode 5, '5:nä peräkkäisenä päivänä 3 tehtävää'
# BadgeDef 'Candy Shop' --- BadgeCode 6, 'Tee 50 tehtävää'
# BadgeDef 'Rakettilähtö' --- BadgeCode 7, 'Tee ekan viikon kaikki tehtävät'
linked_already = BadgeDef.find(1).badge_codes.exists?(BadgeCode.find(1))
BadgeDef.find(1).badge_codes << BadgeCode.find(1) unless linked_already

linked_already = BadgeDef.find(2).badge_codes.exists?(BadgeCode.find(1))
BadgeDef.find(2).badge_codes << BadgeCode.find(1) unless linked_already

linked_already = BadgeDef.find(2).badge_codes.exists?(BadgeCode.find(2))
BadgeDef.find(2).badge_codes << BadgeCode.find(2) unless linked_already

linked_already = BadgeDef.find(3).badge_codes.exists?(BadgeCode.find(1))
BadgeDef.find(3).badge_codes << BadgeCode.find(1) unless linked_already

linked_already = BadgeDef.find(4).badge_codes.exists?(BadgeCode.find(3))
BadgeDef.find(4).badge_codes << BadgeCode.find(3) unless linked_already

linked_already = BadgeDef.find(5).badge_codes.exists?(BadgeCode.find(4))
BadgeDef.find(5).badge_codes << BadgeCode.find(4) unless linked_already

linked_already = BadgeDef.find(6).badge_codes.exists?(BadgeCode.find(5))
BadgeDef.find(6).badge_codes << BadgeCode.find(5) unless linked_already

linked_already = BadgeDef.find(7).badge_codes.exists?(BadgeCode.find(6))
BadgeDef.find(7).badge_codes << BadgeCode.find(6) unless linked_already

linked_already = BadgeDef.find(8).badge_codes.exists?(BadgeCode.find(7))
BadgeDef.find(8).badge_codes << BadgeCode.find(7) unless linked_already
