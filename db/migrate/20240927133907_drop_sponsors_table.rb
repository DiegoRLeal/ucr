class DropSponsorsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :sponsors
  end
end
