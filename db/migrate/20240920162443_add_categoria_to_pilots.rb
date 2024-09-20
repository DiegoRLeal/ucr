class AddCategoriaToPilots < ActiveRecord::Migration[7.1]
  def change
    add_column :pilots, :categoria, :string
  end
end
