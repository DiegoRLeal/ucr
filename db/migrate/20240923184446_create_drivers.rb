class CreateDrivers < ActiveRecord::Migration[7.1]
  def change
    create_table :drivers do |t|
      t.string :car_id
      t.integer :race_number
      t.string :car_model
      t.string :driver_first_name
      t.string :driver_last_name
      t.string :best_lap
      t.string :total_time
      t.integer :lap_count

      t.timestamps
    end
  end
end
