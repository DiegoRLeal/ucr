class AddUcrdriverToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :ucrdriver, :boolean, default: false
  end
end
