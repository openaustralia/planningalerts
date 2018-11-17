# frozen_string_literal: true

class AlertSubscriber < ActiveRecord::Base
  has_many :alerts, dependent: :destroy
end
