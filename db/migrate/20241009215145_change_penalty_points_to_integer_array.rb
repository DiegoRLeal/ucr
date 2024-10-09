class ChangePenaltyPointsToIntegerArray < ActiveRecord::Migration[6.0]
  def up
    # Transformar a string em array de inteiros usando 'string_to_array' no PostgreSQL
    change_column :championships, :penalty_points, :integer, array: true, default: [], using: 'string_to_array(penalty_points, \',\')::integer[]'
  end

  def down
    change_column :championships, :penalty_points, :string
  end
end
