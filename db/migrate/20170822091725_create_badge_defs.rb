class CreateBadgeDefs < ActiveRecord::Migration[5.0]
  def change
    create_table :badge_defs do |t|
      t.string   :name, null: false
      t.string   :iconref
      t.string   :flavor_text
      t.integer  :made_by
      t.boolean  :active, default: 0
      t.boolean  :course_specific, default: 1
      t.boolean  :global, default: 0
      t.integer  :course_id

      t.timestamps
    end
  end
end
