# typed: ignore
# frozen_string_literal: true

class SiteSettingForm
  include ActiveModel::Model
  SiteSettingFormInclude = Virtus.model
  include SiteSettingFormInclude

  attribute :streetview_in_emails_enabled, Boolean
  attribute :streetview_in_app_enabled, Boolean

  # If called without parameters will initialise with the current site settings
  def initialize(params = nil)
    super(params || SiteSetting.settings_with_defaults)
  end

  def persist
    SiteSetting.set(attributes)
  end

  def persisted?
    true
  end
end
