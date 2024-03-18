# typed: strict
# frozen_string_literal: true

class GeocodedLocation < Location
  extend T::Sig

  sig { returns(T.nilable(String)) }
  attr_reader :suburb

  sig { returns(T.nilable(String)) }
  attr_reader :state

  sig { returns(T.nilable(String)) }
  attr_reader :postcode

  sig { returns(String) }
  attr_reader :full_address

  sig do
    params(
      lat: Float,
      lng: Float,
      suburb: T.nilable(String),
      state: T.nilable(String),
      postcode: T.nilable(String),
      full_address: String
    ).void
  end
  def initialize(lat:, lng:, suburb:, state:, postcode:, full_address:)
    @suburb = suburb
    @state = state
    @postcode = postcode
    @full_address = full_address
    super(lat:, lng:)
  end

  sig { returns(T::Hash[Symbol, T.any(String, Float, NilClass)]) }
  def attributes
    {
      lat:,
      lng:,
      suburb:,
      state:,
      postcode:,
      full_address:
    }
  end
end
