class AddYearToChampionships < ActiveRecord::Migration[7.1]
  def change
    add_column :championships, :year, :integer
  end
end
