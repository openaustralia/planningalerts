# frozen_string_literal: true

module Admin
  class SiteSettingsController < ApplicationController
    def update
      # TODO: Simplify this
      SiteSetting.set(:streetview_in_emails_enabled, params[:site_setting][:streetview_in_emails_enabled])
      SiteSetting.set(:streetview_in_app_enabled, params[:site_setting][:streetview_in_app_enabled])
      redirect_to admin_dashboard_url, notice: "Site settings updated"
    end
  end
end
