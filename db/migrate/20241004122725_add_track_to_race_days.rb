class AddTrackToRaceDays < ActiveRecord::Migration[7.1]
  def change
    add_reference :race_days, :track, foreign_key: true
  end
end
