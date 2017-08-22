class CreateBadgeCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :badge_codes do |t|
      t.string   :name, null: false
      t.string   :description
      t.string   :code, null: false
      t.integer  :created_by
      t.integer  :modified_by
      t.boolean  :bugs, default: 0
      t.boolean  :course_points_only, default: 1

      t.timestamps
    end
  end
end
