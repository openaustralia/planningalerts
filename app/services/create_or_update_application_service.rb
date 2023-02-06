# typed: strict
# frozen_string_literal: true

class CreateOrUpdateApplicationService
  extend T::Sig

  sig do
    params(
      authority: Authority,
      council_reference: String,
      attributes: T::Hash[Symbol, T.untyped]
    ).returns(Application)
  end
  def self.call(authority:, council_reference:, attributes:)
    new(
      authority:,
      council_reference:,
      attributes:
    ).call
  end

  sig { params(authority: Authority, council_reference: String, attributes: T::Hash[Symbol, T.untyped]).void }
  def initialize(
    authority:, council_reference:, attributes:
  )
    @authority = authority
    @council_reference = council_reference
    @attributes = T.let(attributes.stringify_keys, T::Hash[String, T.untyped])
    # TODO: Do some sanity checking on the keys in attributes
    # TODO: Make sure that authority_id and council_reference are not
    # keys in attributes
  end

  # Returns created or updated application
  sig { returns(Application) }
  def call
    Application.transaction do
      # First check if record already exists or create a new one if it doesn't
      application = Application.find_by(authority:, council_reference:)
      application = Application.create!(authority:, council_reference:, first_date_scraped: attributes["date_scraped"]) if application.nil?
      create_version(application)
      application.reindex
      application
    end
  end

  private

  sig { returns(Authority) }
  attr_reader :authority

  sig { returns(String) }
  attr_reader :council_reference

  sig { returns(T::Hash[String, T.untyped]) }
  attr_reader :attributes

  sig { params(application: Application).void }
  def create_version(application)
    previous_version = application.current_version
    new_version = ApplicationVersion.build_version(
      application_id: T.must(application.id),
      previous_version:,
      attributes:
    )

    # If none of the data has changed don't save the new version
    # Comparing attributes on model so that typecasting has been done
    return if previous_version && new_version.data_attributes.except("date_scraped") == previous_version.data_attributes.except("date_scraped")

    previous_version&.update(current: false)
    new_version.save!
    application.versions.reload
    application.reload_current_version
  end
end
