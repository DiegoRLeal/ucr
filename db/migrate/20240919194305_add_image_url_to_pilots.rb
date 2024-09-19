class AddImageUrlToPilots < ActiveRecord::Migration[7.1]
  def change
    add_column :pilots, :image_url, :string
  end
end
