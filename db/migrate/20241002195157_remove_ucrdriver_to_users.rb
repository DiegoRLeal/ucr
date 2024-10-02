class RemoveUcrdriverToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :ucrdriver, :boolean
  end
end
