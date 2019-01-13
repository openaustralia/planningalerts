# frozen_string_literal: true

# Stores versioned site settings. This is an append only log where the most
# recent record contains the current settings for the whole site.
# This is used for things like feature flags
class SiteSetting < ApplicationRecord
  serialize :settings

  DEFAULTS = {
    streetview_in_emails_enabled: true,
    streetview_in_app_enabled: true
  }.freeze

  # Note that this doesn't include the default values
  def self.settings
    SiteSetting.order(id: :desc).first&.settings || {}
  end

  def self.set(param, value)
    SiteSetting.create!(settings: settings.merge(param => value))
  end

  def self.get(param)
    raise "Add default value for parameter :#{param} to SiteSetting.DEFAULTS" unless DEFAULTS.key?(param)

    settings.key?(param) ? settings[param] : DEFAULTS[param]
  end
end
