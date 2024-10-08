class User < ApplicationRecord
  has_one_attached :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:steam]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = "#{auth.uid}@steam.com" # A Steam não retorna email, então criamos um email fictício
      user.password = Devise.friendly_token[0, 20]
      user.username = auth.info.nickname # Ou outro campo que você deseja salvar
    end
  end
end
