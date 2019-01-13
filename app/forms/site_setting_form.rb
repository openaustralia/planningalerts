# frozen_string_literal: true

class SiteSettingForm
  include ActiveModel::Model

  attr_accessor :streetview_in_emails_enabled, :streetview_in_app_enabled

  def persisted?
    true
  end
end
