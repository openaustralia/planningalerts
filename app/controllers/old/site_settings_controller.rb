# typed: true
# frozen_string_literal: true

module Old
  class SiteSettingsController < ApplicationController
    def update
      s = SiteSettingForm.new(site_setting)
      s.persist
      redirect_to old_dashboard_url, notice: "Site settings updated"
    end

    private

    class SiteSettingParams < T::Struct
      const :streetview_in_emails_enabled, Integer
      const :streetview_in_app_enabled, Integer
    end

    class WrappedSiteSettingParams < T::Struct
      const :site_setting, SiteSettingParams
    end

    def site_setting
      typed_params = TypedParams[WrappedSiteSettingParams].new.extract!(params)
      typed_params.site_setting.serialize.symbolize_keys
    end
  end
end
