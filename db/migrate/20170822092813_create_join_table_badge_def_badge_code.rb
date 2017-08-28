class CreateJoinTableBadgeDefBadgeCode < ActiveRecord::Migration[5.0]
  def change
    create_join_table :badge_codes, :badge_defs do |t|
      t.index [:badge_code_id, :badge_def_id], :name => 'index_for_badge_code_to_badge_def'
      t.index [:badge_def_id, :badge_code_id], :name => 'index_for_badge_def_to_badge_code'
    end
  end
end
