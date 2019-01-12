# frozen_string_literal: true

# Stores versioned site settings. This is an append only log where the most
# recent record contains the current settings for the whole site.
# This is used for things like feature flags
class SiteSetting < ApplicationRecord
  serialize :settings

  def self.streetview_in_emails_enabled
    get(:streetview_in_emails_enabled, true)
  end

  def self.streetview_in_emails_enabled=(value)
    set(:streetview_in_emails_enabled, value)
  end

  def self.settings
    SiteSetting.order(id: :desc).first&.settings || {}
  end

  def self.set(param, value)
    SiteSetting.create!(settings: settings.merge(param => value))
  end

  def self.get(param, default)
    settings.key?(param) ? settings[param] : default
  end
end
