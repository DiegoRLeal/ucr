class CreateCarNumbers < ActiveRecord::Migration[7.1]
  def change
    create_table :car_numbers do |t|
      t.integer :number
      t.references :race_day, null: false, foreign_key: true

      t.timestamps
    end
  end
end
