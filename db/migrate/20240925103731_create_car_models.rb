class CreateCarModels < ActiveRecord::Migration[7.1]
  def change
    create_table :car_models do |t|
      t.string :car_id
      t.string :car_name

      t.timestamps
    end
  end
end
