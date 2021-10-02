# typed: false
# frozen_string_literal: true

class SiteSettingForm
  extend T::Sig

  include ActiveModel::Model
  # See https://sorbet.org/docs/error-reference#4002
  T.unsafe(self).include Virtus.model

  attribute :streetview_in_emails_enabled, Virtus::Attribute::Boolean
  attribute :streetview_in_app_enabled, Virtus::Attribute::Boolean

  # If called without parameters will initialise with the current site settings
  sig { params(params: T.nilable(T::Hash[Symbol, T.untyped])).void }
  def initialize(params = nil)
    super(params || SiteSetting.settings_with_defaults)
  end

  sig { void }
  def persist
    SiteSetting.set(attributes)
  end

  sig { returns(T::Boolean) }
  def persisted?
    true
  end
end
