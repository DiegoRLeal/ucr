class AddCupCategoryToChampionships < ActiveRecord::Migration[7.1]
  def change
    add_column :championships, :cup_category, :integer
  end
end
