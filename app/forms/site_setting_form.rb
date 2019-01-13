# frozen_string_literal: true

class SiteSettingForm
  include ActiveModel::Model
  include Virtus.model

  attribute :streetview_in_emails_enabled, Boolean
  attribute :streetview_in_app_enabled, Boolean

  def persisted?
    true
  end
end
