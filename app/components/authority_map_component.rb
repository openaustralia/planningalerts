# typed: strict
# frozen_string_literal: true

class AuthorityMapComponent < ViewComponent::Base
  extend T::Sig

  sig { params(authority: Authority).void }
  def initialize(authority:)
    super()
    @authority = authority
  end

  # Used as a fallback when the map javascript can't be loaded, for example
  # because a content blocker is blocking maps.googleapis.com. An authority is
  # a boundary rather than a point, so search Google Maps by name instead of
  # linking to a lat/lng.
  sig { returns(String) }
  def google_maps_url
    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(@authority.full_name)}"
  end

  # TODO: #2164 Probably want to precompute the bounding box when the boundary data is loaded instead
  sig { returns(String) }
  def map_params_json
    bb = RGeo::Cartesian::BoundingBox.create_from_geometry(@authority.boundary)
    {
      json: helpers.boundary_authority_url(@authority.short_name_encoded, format: :json),
      sw: { lng: bb.min_x, lat: bb.min_y },
      ne: { lng: bb.max_x, lat: bb.max_y }
    }.to_json
  end
end
