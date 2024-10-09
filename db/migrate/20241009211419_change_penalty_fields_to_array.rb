class ChangePenaltyFieldsToArray < ActiveRecord::Migration[6.0]
  def up
    # Etapa 1: Alterar temporariamente as colunas para text
    change_column :championships, :penalty_value, :text
    change_column :championships, :penalty_violation_in_lap, :text
    change_column :championships, :penalty_cleared_in_lap, :text

    # Etapa 2: Atualizar os valores para arrays corretamente
    execute "UPDATE championships SET penalty_value = ARRAY[penalty_value::integer] WHERE penalty_value IS NOT NULL;"
    execute "UPDATE championships SET penalty_violation_in_lap = ARRAY[penalty_violation_in_lap::integer] WHERE penalty_violation_in_lap IS NOT NULL;"
    execute "UPDATE championships SET penalty_cleared_in_lap = ARRAY[penalty_cleared_in_lap::integer] WHERE penalty_cleared_in_lap IS NOT NULL;"

    # Etapa 3: Alterar as colunas para arrays de inteiros
    change_column :championships, :penalty_value, 'integer[]', using: 'penalty_value::integer[]', default: []
    change_column :championships, :penalty_violation_in_lap, 'integer[]', using: 'penalty_violation_in_lap::integer[]', default: []
    change_column :championships, :penalty_cleared_in_lap, 'integer[]', using: 'penalty_cleared_in_lap::integer[]', default: []
  end

  def down
    # Reverter as colunas para o estado anterior
    change_column :championships, :penalty_value, :integer
    change_column :championships, :penalty_violation_in_lap, :integer
    change_column :championships, :penalty_cleared_in_lap, :integer
  end
end
