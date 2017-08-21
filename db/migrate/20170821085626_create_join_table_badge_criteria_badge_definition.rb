class CreateJoinTableBadgeCriteriaBadgeDefinition < ActiveRecord::Migration[5.0]
  def change
    create_join_table :badge_criteria, :badge_definitions do |t|
      t.index [:badge_criterium_id, :badge_definition_id], :name => 'index_for_badge_crit_to_badge_def'
      t.index [:badge_definition_id, :badge_criterium_id], :name => 'index_for_badge_def_to_badge_crit'
    end
  end
end
