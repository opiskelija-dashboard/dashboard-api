# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])

#   Character.create(name: 'Luke', movie: movies.first)

Point.create(exercise_id: 2, point_id: 3, course_id: 1,
  user_id: 1, submission_id: 2, name: "teht 2.2")
Point.create(exercise_id: 1, point_id: 1, course_id: 1,
  user_id: 1, submission_id: 1, name: "teht 1")
Point.create(exercise_id: 2, point_id: 2, course_id: 1,
  user_id: 1, submission_id: 2, name: "teht 2.1")

