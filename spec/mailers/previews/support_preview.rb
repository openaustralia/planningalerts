# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

require "factory_bot_rails"

class SupportPreview < ActionMailer::Preview
  def abuse_report
    report = FactoryBot.build_stubbed(:report)
    SupportMailer.report(report)
  end
end
