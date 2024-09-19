class CreatePilots < ActiveRecord::Migration[7.1]
  def change
    create_table :pilots do |t|
      t.string :name
      t.string :instagram
      t.string :twitch
      t.string :youtube

      t.timestamps
    end
  end
end
