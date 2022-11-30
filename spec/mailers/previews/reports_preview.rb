# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

require "factory_bot_rails"

class ReportsPreview < ActionMailer::Preview
  def notify
    report = FactoryBot.build_stubbed(:report)
    ReportMailer.notify(report)
  end
end
