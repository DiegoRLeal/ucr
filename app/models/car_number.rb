class CarNumber < ApplicationRecord
  belongs_to :race_day
  has_one :pilot_registration

  # Escopo para mostrar números de carro que ainda não têm uma inscrição associada
  scope :available, -> { left_joins(:pilot_registration).where(pilot_registrations: { id: nil }).where.not(number: nil) }

  validates :number, presence: true  # Certifique-se de que essa validação não está falhando
end
