class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :organisation, :password, :password_confirmation,
    :remember_me, :bulk_api, :admin
  before_create :set_api_key

  def set_api_key
    self.api_key = Digest::MD5.base64digest(id.to_s + rand.to_s + Time.now.to_s)[0...20]
  end
end
