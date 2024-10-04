class PilotRegistration < ApplicationRecord
  belongs_to :race_day
  belongs_to :car_number, optional: true
  validates :pilot_name, presence: true

  # validate :check_max_pilots, on: :create

  # def check_max_pilots
  #   if race_day.pilot_registrations.count >= race_day.max_pilots
  #     errors.add(:base, 'As inscrições estão completas. Você foi adicionado à lista de espera.')
  #   end
  # end
end
