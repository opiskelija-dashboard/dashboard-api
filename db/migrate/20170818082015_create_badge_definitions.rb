class CreateBadgeDefinitions < ActiveRecord::Migration[5.0]
  def change
    create_table :badge_definitions do |t|
      t.string   :name
      t.string   :criteria
      t.boolean  :global
      t.boolean  :course_specific
      t.boolean  :active

      t.timestamps
    end
  end
end
