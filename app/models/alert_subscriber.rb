# frozen_string_literal: true

class AlertSubscriber < ApplicationRecord
  has_many :alerts, dependent: :destroy
end
