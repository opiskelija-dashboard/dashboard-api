class DestroyCourseIdColumnInBadges < ActiveRecord::Migration[5.0]
  def change
    remove_column :badges, :course_id
  end
end
