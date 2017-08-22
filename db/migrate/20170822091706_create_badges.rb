class CreateBadges < ActiveRecord::Migration[5.0]
  def change
    create_table :badges do |t|
      t.integer  :badge_definition_id, null: false
      t.integer  :user_id, null: false
      t.integer  :course_id

      t.timestamps
    end
  end
end
