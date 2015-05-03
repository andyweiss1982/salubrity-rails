class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.name = auth.info.first_name
        user.password = Devise.friendly_token[0,20]
        user.token = auth.credentials.token
      end
  end

  def ping_facebook
    require 'httparty'
    response = HTTParty.get("https://graph.facebook.com/v2.3/#{self.uid}/friends?access_token=#{self.token}")
    puts response.body
  end
end
