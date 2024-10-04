class AddPenaltyPointsToChampionships < ActiveRecord::Migration[7.1]
  def change
    add_column :championships, :penalty_points, :integer
  end
end
