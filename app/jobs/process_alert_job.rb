# typed: true
# frozen_string_literal: true

class ProcessAlertJob < ApplicationJob
  queue_as :default

  def perform(id)
    ProcessAlertAndRecordStatsService.call(alert_id: id)
  end
end
