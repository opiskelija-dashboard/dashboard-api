class CreatePoints < ActiveRecord::Migration[5.0]
  def change
    create_table :points do |t|
      t.integer :exercise_id
      t.integer :point_id
      t.integer :course_id
      t.integer :user_id
      t.integer :submission_id
      t.string :name

      t.timestamps
    end
  end
end
