class CreateResults < ActiveRecord::Migration[7.1]
  def change
    create_table :results do |t|
      t.string :first_name
      t.string :last_name
      t.string :email

      t.timestamps
    end
  end
end
