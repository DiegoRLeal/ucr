class AddNumberToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :number, :string
  end
end
