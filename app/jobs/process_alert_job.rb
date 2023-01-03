# typed: strict
# frozen_string_literal: true

class ProcessAlertJob < ApplicationJob
  extend T::Sig

  queue_as :default

  sig { params(id: Integer).void }
  def perform(id)
    alert = Alert.find(id)
    ProcessAlertAndRecordStatsService.call(alert:)
  end
end
