class CreatePilotRegistrations < ActiveRecord::Migration[7.1]
  def change
    create_table :pilot_registrations do |t|
      t.string :pilot_name
      t.references :race_day, null: false, foreign_key: true
      t.references :car_number, null: false, foreign_key: true

      t.timestamps
    end
  end
end
