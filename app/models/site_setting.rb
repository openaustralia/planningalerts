# frozen_string_literal: true

# Stores versioned site settings. This is an append only log where the most
# recent record contains the current settings for the whole site.
# This is used for things like feature flags
class SiteSetting < ApplicationRecord
  serialize :settings

  def self.streetview_in_emails_enabled
    if settings.key?(:streetview_in_emails_enabled)
      settings[:streetview_in_emails_enabled]
    else
      true
    end
  end

  def self.streetview_in_emails_enabled=(value)
    SiteSetting.create!(settings: settings.merge(streetview_in_emails_enabled: value))
  end

  def self.settings
    SiteSetting.order(id: :desc).first&.settings || {}
  end
end
