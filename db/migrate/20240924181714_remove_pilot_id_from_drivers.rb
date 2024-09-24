class RemovePilotIdFromDrivers < ActiveRecord::Migration[7.1]
  def change
    remove_column :drivers, :pilot_id, :integer
  end
end
