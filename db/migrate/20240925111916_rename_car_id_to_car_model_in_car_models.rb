class RenameCarIdToCarModelInCarModels < ActiveRecord::Migration[6.1]
  def change
    rename_column :car_models, :car_id, :car_model
  end
end
