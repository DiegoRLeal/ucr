class AddLapsToDrivers < ActiveRecord::Migration[7.1]
  def change
    add_column :drivers, :laps, :text
  end
end
