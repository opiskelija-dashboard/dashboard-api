class DropPointsAndSubmissions < ActiveRecord::Migration[5.0]
  def change
    drop_table :submissions
    drop_table :points
  end
end
