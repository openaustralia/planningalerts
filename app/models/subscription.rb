class Subscription < ActiveRecord::Base
  has_many :alerts, foreign_key: :email, primary_key: :email
end

