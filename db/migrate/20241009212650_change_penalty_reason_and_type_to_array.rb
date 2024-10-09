class ChangePenaltyReasonAndTypeToArray < ActiveRecord::Migration[6.1]
  def up
    # Altere as colunas penalty_reason e penalty_type para arrays, especificando o 'USING'
    change_column :championships, :penalty_reason, "varchar[]", using: "string_to_array(penalty_reason, ',')", default: []
    change_column :championships, :penalty_type, "varchar[]", using: "string_to_array(penalty_type, ',')", default: []
  end

  def down
    # Reverter as colunas para string simples
    change_column :championships, :penalty_reason, :string
    change_column :championships, :penalty_type, :string
  end
end
