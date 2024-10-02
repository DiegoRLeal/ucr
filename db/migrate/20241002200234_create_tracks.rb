class CreateTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :tracks do |t|
      t.string :track_id
      t.string :track_name

      t.timestamps
    end
  end
end
