class FixModifiersInBadgeCodes < ActiveRecord::Migration[5.0]
  def change
    rename_column :badge_codes, :course_points_only, :course_points
    add_column :badge_codes, :user_points, :boolean
    add_column :badge_codes, :exercises, :boolean
  end
end
