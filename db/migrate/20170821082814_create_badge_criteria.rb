class CreateBadgeCriteria < ActiveRecord::Migration[5.0]
  def change
    create_table :badge_criteria do |t|
      t.string   :name
      t.string   :description
      t.string   :code
      t.integer  :created_by
      t.integer  :modified_by
      t.boolean  :bugs
      t.boolean  :course_points_only

      t.timestamps
    end
  end
end
