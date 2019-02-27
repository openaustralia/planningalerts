# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable
  before_create :set_api_key

  def set_api_key
    self.api_key = Digest::MD5.base64digest(id.to_s + rand.to_s + Time.zone.now.to_s)[0...20]
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
