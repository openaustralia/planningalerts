class AlertSubscriber < ActiveRecord::Base
  has_many :alerts

  validates :email, presence: true, uniqueness: true
end
