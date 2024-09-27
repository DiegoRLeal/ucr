class CreateSponsors < ActiveRecord::Migration[7.1]
  def change
    create_table :sponsors do |t|
      t.string :nome
      t.string :image_url

      t.timestamps
    end
  end
end
