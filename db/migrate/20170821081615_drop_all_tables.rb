class DropAllTables < ActiveRecord::Migration[5.0]
  def change
    drop_table(:awarded_badges, if_exists: true)
    drop_table(:course_badges, if_exists: true)
    drop_table(:badge_definitions, if_exists: true)
    drop_table(:badge_criteria, if_exists: true)
    drop_table(:badge_criteria_definitions, if_exists: true)
  end
end
