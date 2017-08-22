class CreateBadgeDefs < ActiveRecord::Migration[5.0]
  def change
    create_table :badge_defs do |t|
      t.string   :name
      t.string   :iconref
      t.string   :flavor_text
      t.integer  :made_by
      t.boolean  :active
      t.boolean  :course_specific
      t.boolean  :global
      t.integer  :course_id

      t.timestamps
    end
  end
end
