# typed: true
# frozen_string_literal: true

class SiteSettingForm
  include ActiveModel::Model
  # See https://sorbet.org/docs/error-reference#4002
  T.unsafe(self).include Virtus.model

  attribute :streetview_in_emails_enabled, Virtus::Attribute::Boolean
  attribute :streetview_in_app_enabled, Virtus::Attribute::Boolean

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
