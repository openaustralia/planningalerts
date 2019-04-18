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
    key_attributes = {
      authority: authority, council_reference: council_reference
    }
    # First check if record already exists
    application = Application.find_by(key_attributes) ||
                  Application.create!(key_attributes)
    application.create_version(attributes)
    application
  end

  private

  attr_reader :authority, :council_reference, :attributes
end
