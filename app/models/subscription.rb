class Subscription < ActiveRecord::Base
  has_many :alerts, foreign_key: :email, primary_key: :email

  def self.create_trial_subscription_for(email)
    self.create!(email: email, trial_days_remaining: 14)
  end
end

