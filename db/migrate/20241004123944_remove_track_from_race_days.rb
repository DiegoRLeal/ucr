class RemoveTrackFromRaceDays < ActiveRecord::Migration[7.1]
  def change
    remove_column :race_days, :track, :string
  end
end
