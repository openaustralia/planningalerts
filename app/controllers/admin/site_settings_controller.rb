# frozen_string_literal: true

module Admin
  class SiteSettingsController < ApplicationController
    def update
      SiteSetting.set(params[:site_setting].permit!)
      redirect_to admin_dashboard_url, notice: "Site settings updated"
    end
  end
end
