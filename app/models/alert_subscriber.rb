class AlertSubscriber < ActiveRecord::Base
  has_many :alerts
  attr_reader :email

  def initialize(email: nil)
    @email = email
  end

  # TODO: Extract generic new_subscribers_for_date
  def self.subscribed_one_week_ago
    date = 1.week.ago.to_date
    alerts = Alert.active.where("date(created_at) = ?", date).group(:email)

    # Remove people who signed up before that date
    alerts = alerts.reject do |alert|
      Alert.where(email: alert.email).where("created_at < ?", alert.created_at).any?
    end

    alerts.collect do |alert|
      AlertSubscriber.new(email: alert.email)
    end
  end
end
