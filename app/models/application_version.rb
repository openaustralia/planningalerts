# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  belongs_to :application
  belongs_to :previous_version, class_name: "ApplicationVersion", optional: true

  validates :date_scraped, :address, :description, presence: true
  validates :info_url, url: true
  validates :comment_url, url: { allow_blank: true, schemes: %w[http https mailto] }
  validate :date_received_can_not_be_in_the_future, :validate_on_notice_period

  validates :current, uniqueness: { scope: :application_id }, if: :current

  delegate :authority, :council_reference, to: :application

  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat: lat, lng: lng) if lat && lng
  end

  private

  def date_received_can_not_be_in_the_future
    return unless date_received && date_received > Time.zone.today

    errors.add(:date_received, "can not be in the future")
  end

  def validate_on_notice_period
    return unless on_notice_from || on_notice_to

    if on_notice_from.nil?
      # errors.add(:on_notice_from, "can not be empty if end of on notice period is set")
    elsif on_notice_to.nil?
      # errors.add(:on_notice_to, "can not be empty if start of on notice period is set")
    elsif on_notice_from > on_notice_to
      errors.add(:on_notice_to, "can not be earlier than the start of the on notice period")
    end
  end
end
