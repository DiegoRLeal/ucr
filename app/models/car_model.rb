class CarModel < ApplicationRecord
  has_many :drivers, foreign_key: 'car_model', primary_key: 'car_model'
  has_many :championships, foreign_key: 'car_model', primary_key: 'car_model'

  def to_s
    car_name  # Supondo que você tenha um campo 'car_name' ou similar
  end
end
