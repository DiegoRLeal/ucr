class AddPenaltiesToDrivers < ActiveRecord::Migration[7.1]
  def change
    add_column :drivers, :penalty_reason, :string
    add_column :drivers, :penalty_type, :string
    add_column :drivers, :penalty_value, :integer
    add_column :drivers, :penalty_violation_in_lap, :integer
    add_column :drivers, :penalty_cleared_in_lap, :integer
    add_column :drivers, :post_race_penalty_reason, :string
    add_column :drivers, :post_race_penalty_type, :string
    add_column :drivers, :post_race_penalty_value, :integer
    add_column :drivers, :post_race_penalty_violation_in_lap, :integer
    add_column :drivers, :post_race_penalty_cleared_in_lap, :integer
  end
end
