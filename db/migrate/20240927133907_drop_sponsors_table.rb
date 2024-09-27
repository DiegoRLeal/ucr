class DropSponsorsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :sponsors if table_exists?(:sponsors)
  end
end

