class DeletePointsFromSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :submissions, :points
  end
end
