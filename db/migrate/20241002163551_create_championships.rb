class CreateChampionships < ActiveRecord::Migration[7.1]
  def change
    create_table :championships do |t|
      t.string :car_id
      t.integer :race_number
      t.string :car_model
      t.string :driver_first_name
      t.string :driver_last_name
      t.string :best_lap
      t.string :total_time
      t.integer :lap_count
      t.date :session_date
      t.time :session_time
      t.string :session_type
      t.string :track_name
      t.text :laps
      t.string :penalty_reason
      t.string :penalty_type
      t.integer :penalty_value
      t.integer :penalty_violation_in_lap
      t.integer :penalty_cleared_in_lap
      t.string :post_race_penalty_reason
      t.string :post_race_penalty_type
      t.integer :post_race_penalty_value
      t.integer :post_race_penalty_violation_in_lap
      t.integer :post_race_penalty_cleared_in_lap
      t.integer :points

      t.timestamps
    end
  end
end
