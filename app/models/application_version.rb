# typed: strict
# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  extend T::Sig

  belongs_to :application
  belongs_to :previous_version, class_name: "ApplicationVersion", optional: true

  validates :date_scraped, :address, :description, presence: true
  validates :info_url, url: true
  validate :date_received_can_not_be_in_the_future, :validate_on_notice_period

  validates :current, uniqueness: { scope: :application_id }, if: :current

  delegate :authority, :council_reference, to: :application

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def search_data
    # lat and lon need to be symbols (rather than strings) in search_data
    # to get valid data come through searchkick for some reason
    attributes.symbolize_keys.merge(location: { lat:, lon: lng })
  end

  # TODO: factor out common location accessor between Application and Alert
  sig { returns(T.nilable(Location)) }
  def location
    Location.build(lat:, lng:)
  end

  sig { returns(T::Hash[String, T.untyped]) }
  def data_attributes
    attributes.except(
      "id", "created_at", "updated_at", "application_id",
      "previous_version_id", "current"
    )
  end

  sig { returns(T::Hash[String, T.untyped]) }
  def changed_data_attributes
    v = previous_version
    if v
      changed = {}
      data_attributes.each_key do |a|
        changed[a] = data_attributes[a] unless data_attributes[a] == v.data_attributes[a]
      end
      changed
    else
      # If this is the first version it's all changed!
      data_attributes
    end
  end

  sig do
    params(
      application_id: Integer,
      previous_version: T.nilable(ApplicationVersion),
      attributes: T::Hash[String, T.untyped]
    ).returns(ApplicationVersion)
  end
  def self.build_version(application_id:, previous_version:, attributes:)
    new(
      (previous_version&.data_attributes || {})
        .merge(attributes)
        .merge(
          "application_id" => application_id,
          "previous_version_id" => previous_version&.id,
          "current" => true
        )
    )
  end

  sig { returns(T::Boolean) }
  def official_submission_period_expired?
    !on_notice_to.nil? && Time.zone.today > on_notice_to
  end

  private

  sig { void }
  def date_received_can_not_be_in_the_future
    d = date_received
    return unless d && d > Time.zone.today

    errors.add(:date_received, "can not be in the future")
  end

  sig { void }
  def validate_on_notice_period
    from = on_notice_from
    to = on_notice_to

    return unless from && to && from > to

    errors.add(:on_notice_to, "can not be earlier than the start of the on notice period")
  end
end
