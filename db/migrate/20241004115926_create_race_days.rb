class CreateRaceDays < ActiveRecord::Migration[7.1]
  def change
    create_table :race_days do |t|
      t.date :date
      t.string :track
      t.integer :max_pilots

      t.timestamps
    end
  end
end
