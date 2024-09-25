class AddPointsToDrivers < ActiveRecord::Migration[7.1]
  def change
    add_column :drivers, :points, :integer
  end
end
