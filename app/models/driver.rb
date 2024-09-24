class Driver < ApplicationRecord
  serialize :laps, JSON  # Serializar as voltas como JSON
end
