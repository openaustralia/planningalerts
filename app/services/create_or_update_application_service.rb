# typed: strict
# frozen_string_literal: true

class CreateOrUpdateApplicationService
  extend T::Sig

  VALID_ATTRIBUTES = T.let(
    %i[address description info_url date_received on_notice_from on_notice_to date_scraped lat lng lonlat suburb state postcode comment_email comment_authority].freeze,
    T::Array[Symbol]
  )

  # Returns created or updated application
  sig do
    params(
      authority: Authority,
      council_reference: String,
      attributes: T::Hash[Symbol, T.untyped]
    ).returns(Application)
  end
  def self.call(authority:, council_reference:, attributes:)
    attributes.each_key do |key|
      raise "Invalid attribute #{key}" unless VALID_ATTRIBUTES.include?(key)
    end

    Application.transaction do
      # First check if record already exists or create a new one if it doesn't
      application = Application.find_by(authority:, council_reference:) || Application.new(authority:, council_reference:, first_date_scraped: attributes[:date_scraped])
      application.address = attributes[:address] if attributes.key?(:address)

      # Geocode if address has changed and it hasn't already been geocoded (by passing in lat and lng from the outside)
      attributes = attributes.merge(Application.geocode_attributes(attributes[:address])) if application.address_changed? && !(attributes[:lat] && attributes[:lng] && attributes[:suburb] && attributes[:state] && attributes[:postcode])

      # If it's just the date_scraped changing and nothing else we don't want to alter the object
      application.assign_attributes(attributes.except(:date_scraped))

      # If none of the data has changed then don't save a new version
      unless application.changed_attributes.empty?
        application.date_scraped = attributes[:date_scraped] if attributes.key?(:date_scraped)
        application.save!
        create_version(application, attributes)
        application.reindex
      end
      application
    end
  end

  sig { params(application: Application, attributes: T::Hash[Symbol, T.untyped]).void }
  def self.create_version(application, attributes)
    previous_version = application.current_version
    new_version = ApplicationVersion.build_version(
      application_id: application.id,
      previous_version:,
      attributes: attributes.stringify_keys
    )

    previous_version&.update(current: false)
    new_version.save!
    application.versions.reload
    application.reload_current_version
  end
end
