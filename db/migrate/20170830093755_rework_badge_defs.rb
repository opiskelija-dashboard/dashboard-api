class ReworkBadgeDefs < ActiveRecord::Migration[5.0]
  def change
    remove_column :badge_defs, :global
    remove_column :badge_defs, :course_specific
  end
end
