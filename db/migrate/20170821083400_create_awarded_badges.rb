class CreateAwardedBadges < ActiveRecord::Migration[5.0]
  def change
    create_table :awarded_badges do |t|
      t.integer  :badge_definition_id
      t.integer  :user_id
      t.integer  :course_id

      t.timestamps
    end
  end
end