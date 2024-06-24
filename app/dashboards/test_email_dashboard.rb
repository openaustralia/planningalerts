# typed: strict
# frozen_string_literal: true

require "administrate/custom_dashboard"

class TestEmailDashboard < Administrate::CustomDashboard
  resource "TestEmails"
end
