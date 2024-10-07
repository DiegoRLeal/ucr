class AddSeasonAndYearToChampionships < ActiveRecord::Migration[7.1]
  def change
    add_column :championships, :season, :string
  end
end
