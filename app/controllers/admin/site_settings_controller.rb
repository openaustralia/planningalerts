# typed: strict
# frozen_string_literal: true

module Admin
  class SiteSettingsController < Admin::ApplicationController
    extend T::Sig

    sig { void }
    def index; end

    sig { void }
    def update
      s = SiteSettingForm.new(site_setting)
      s.persist
      redirect_to admin_site_settings_url, notice: t(".success")
    end

    private

    class SiteSettingParams < T::Struct
      const :streetview_in_emails_enabled, Integer
      const :streetview_in_app_enabled, Integer
    end

    class WrappedSiteSettingParams < T::Struct
      const :site_setting, SiteSettingParams
    end

    sig { returns(T::Hash[Symbol, Integer]) }
    def site_setting
      params_site_setting = T.cast(params[:site_setting], ActionController::Parameters)
      {
        streetview_in_emails_enabled: params_site_setting[:streetview_in_emails_enabled],
        streetview_in_app_enabled: params_site_setting[:streetview_in_app_enabled]
      }
    end
  end
end
