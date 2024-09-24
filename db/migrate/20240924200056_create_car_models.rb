class CreateCarModels < ActiveRecord::Migration[7.1]
  def change
    create_table :car_models do |t|
      t.string :car_name
      t.integer :car_id

      t.timestamps
    end
  end
end
