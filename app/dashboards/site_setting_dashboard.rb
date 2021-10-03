# typed: true
# frozen_string_literal: true

require "administrate/custom_dashboard"

class SiteSettingDashboard < Administrate::CustomDashboard
  resource "SiteSettings"
end
