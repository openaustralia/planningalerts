# frozen_string_literal: true

class ProcessAlertsBatchJob < ApplicationJob
  queue_as :default

  def perform(alert_ids)
    ProcessAlertsBatchService.call(alert_ids: alert_ids)
  end
end
