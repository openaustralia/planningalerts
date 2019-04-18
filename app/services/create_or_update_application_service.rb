# frozen_string_literal: true

class CreateOrUpdateApplicationService < ApplicationService
  def initialize(
    authority:, council_reference:, attributes:
  )
    @authority = authority
    @council_reference = council_reference
    @attributes = attributes
    # TODO: Do some sanity checking on the keys in attributes
    # TODO: Make sure that authority_id and council_reference are not
    # keys in attributes
  end

  # Returns created or updated application
  def call
    # First check if record already exists or create a new one if it doesn't
    application = Application.find_or_create_by!(
      authority: authority, council_reference: council_reference
    )
    create_version(application)
    application
  end

  private

  attr_reader :authority, :council_reference, :attributes

  def create_version(application)
    # If none of the data has changed don't save a new version
    return if application.current_version && attributes == application.current_version.attributes.symbolize_keys.slice(*attributes.keys)

    application.current_version&.update(current: false)
    application.versions.create!(current_attributes(application).merge(attributes).merge(previous_version: application.current_version, current: true))
    application.reload_current_version
  end

  def current_attributes(application)
    current_attributes = if application.current_version
                           application.current_version.attributes
                         else
                           {}
                         end
    current_attributes = current_attributes.symbolize_keys
    current_attributes.delete(:id)
    current_attributes.delete(:created_at)
    current_attributes.delete(:updated_at)
    current_attributes
  end
end
