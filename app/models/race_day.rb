class RaceDay < ApplicationRecord
  belongs_to :track
  has_many :car_numbers, dependent: :destroy
  has_many :pilot_registrations

  validates :date, :track, :max_pilots, presence: true

  # Após a criação de um RaceDay, gerar automaticamente números de carros de 1 a 999
  after_create :generate_car_numbers


  # Sobrescreve o método to_s para exibir o nome da pista e a data da corrida
  def to_s
    track_name = track.present? ? track : "Pista indefinida"
    race_date = date.present? ? date.strftime('%d/%m/%Y') : "Data não definida"
    "#{track_name} - #{race_date}"
  end

  private

  def generate_car_numbers
    (1..999).each do |number|
      car_numbers.create!(number: number)  # Certifique-se de usar `create!` para garantir que os números sejam salvos corretamente
    end
  end
end
