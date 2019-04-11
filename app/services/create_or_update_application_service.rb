# frozen_string_literal: true

class CreateOrUpdateApplicationService < ApplicationService
  def initialize(
    authority_id:, council_reference:, attributes:
  )
    @authority_id = authority_id
    @council_reference = council_reference
    @attributes = attributes
    # TODO: Do some sanity checking on the keys in attributes
    # TODO: Make sure that authority_id and council_reference are not
    # keys in attributes
  end

  # Returns created or updated application
  def call
    key_attributes = {
      authority_id: authority_id, council_reference: council_reference
    }
    # First check if record already exists
    application = Application.find_by(key_attributes)
    if application
      application.update!(attributes)
    else
      application = Application.create!(attributes.merge(key_attributes))
    end
    application.create_version
    application
  end

  private

  attr_reader :authority_id, :council_reference, :attributes
end
