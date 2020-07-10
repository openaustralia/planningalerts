# typed: false
# frozen_string_literal: true

module Admin
  class SiteSettingsController < ApplicationController
    def update
      s = SiteSettingForm.new(site_setting)
      s.persist
      redirect_to admin_dashboard_url, notice: "Site settings updated"
    end

    private

    def site_setting
      params[:site_setting].permit(
        :streetview_in_emails_enabled,
        :streetview_in_app_enabled
      ).to_h.symbolize_keys
    end
  end
end
