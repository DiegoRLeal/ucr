class Track < ApplicationRecord
  has_many :race_days
  has_many :drivers
  has_many :championships

  def to_s
    track_name  # Isso fará com que o Rails Admin exiba o nome da pista ao invés de "Track #1"
  end
end
