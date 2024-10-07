class ChangePenaltyPointsToBeStringInChampionships < ActiveRecord::Migration[6.0]
  def change
    change_column :championships, :penalty_points, :string
  end
end
