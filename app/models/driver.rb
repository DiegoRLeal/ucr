class Driver < ApplicationRecord
  belongs_to :car_model, foreign_key: :car_model, primary_key: :car_id
  serialize :laps, JSON  # Serializar as voltas como JSON
end
