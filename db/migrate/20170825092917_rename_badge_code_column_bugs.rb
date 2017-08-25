class RenameBadgeCodeColumnBugs < ActiveRecord::Migration[5.0]
  def change
    rename_column :badge_codes, :bugs, :active
  end
end
