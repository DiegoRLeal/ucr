class AddSessionFieldsToDrivers < ActiveRecord::Migration[7.1]
  def change
    add_column :drivers, :session_date, :date
    add_column :drivers, :session_time, :time
    add_column :drivers, :session_type, :string
    add_column :drivers, :track_name, :string
  end
end
