# typed: strict
# frozen_string_literal: true

module ApiHowtoHelper
  extend T::Sig

  include ApplicationsHelper

  # See https://sorbet.org/docs/error-reference#4002
  T.unsafe(self).include Rails.application.routes.url_helpers

  sig { params(url: String).returns(String) }
  def htmlify(url)
    # Sorry about this ugly and longwinded way of doing this
    first, query_text = url.split("?")
    query_htmlified = Rack::Utils.parse_nested_query(query_text).map do |key, value|
      safe_join([content_tag(:strong, key), "=", value])
    end
    query = safe_join(query_htmlified, "&")
    safe_join([first, "?", query])
  end

  sig { returns(T.nilable(String)) }
  def api_key
    current_user&.api_keys&.first&.value
  end

  sig do
    params(
      format: String,
      key: T.nilable(String),
      lat: T.any(Float, String),
      lng: T.any(Float, String),
      radius: T.any(Integer, String)
    ).returns(String)
  end
  def api_example_latlong_url(
    format, key, lat = Rails.configuration.planningalerts_api_example_lat, lng = Rails.configuration.planningalerts_api_example_lng,
    radius = Rails.configuration.planningalerts_api_example_size
  )
    applications_url(host: api_host, format: format, lat: lat, lng: lng, radius: radius, key: key)
  end

  sig do
    params(
      format: String,
      key: T.nilable(String),
      bottom_left_lat: T.any(Float, String),
      bottom_left_lng: T.any(Float, String),
      top_right_lat: T.any(Float, String),
      top_right_lng: T.any(Float, String)
    ).returns(String)
  end
  def api_example_area_url(
    format, key, bottom_left_lat = Rails.configuration.planningalerts_api_example_bottom_left_lat,
    bottom_left_lng = Rails.configuration.planningalerts_api_example_bottom_left_lng,
    top_right_lat = Rails.configuration.planningalerts_api_example_top_right_lat,
    top_right_lng = Rails.configuration.planningalerts_api_example_top_right_lng
  )
    applications_url(
      host: api_host, format: format,
      bottom_left_lat: bottom_left_lat, bottom_left_lng: bottom_left_lng,
      top_right_lat: top_right_lat, top_right_lng: top_right_lng,
      key: key
    )
  end

  sig { params(format: String, key: T.nilable(String), authority: String).returns(String) }
  def api_example_authority_url(format, key, authority = Rails.configuration.planningalerts_api_example_authority)
    authority_applications_url(
      host: api_host, format: format, authority_id: authority,
      key: key
    )
  end

  sig do
    params(
      format: String,
      key: T.nilable(String),
      postcode: String,
      extra_params: T::Hash[Symbol, T.any(String, Integer)]
    ).returns(String)
  end
  def api_example_postcode_url(format, key, postcode = Rails.configuration.planningalerts_api_example_postcode, extra_params = {})
    T.unsafe(self).applications_url({ host: api_host, format: format, postcode: postcode, key: key }.merge(extra_params))
  end

  sig do
    params(
      format: String,
      key: T.nilable(String),
      suburb: String,
      state: String,
      postcode: String
    ).returns(String)
  end
  def api_example_suburb_state_and_postcode_url(
    format,
    key,
    suburb = Rails.configuration.planningalerts_api_example_suburb,
    state = Rails.configuration.planningalerts_api_example_state,
    postcode = Rails.configuration.planningalerts_api_example_postcode
  )
    applications_url(
      host: api_host, format: format, suburb: suburb, state: state, postcode: postcode,
      key: key
    )
  end

  sig { params(format: String, key: T.nilable(String)).returns(String) }
  def api_example_latlong_url_html(format, key)
    t = api_example_latlong_url(format, key || "44", "11", "22", "33")
    t = t.sub("11", "[latitude]")
    t = t.sub("22", "[longitude]")
    t = t.sub("33", "[distance_in_metres]")
    t = t.sub("44", "[key]") if key.nil?
    htmlify(t)
  end

  sig { params(format: String, key: T.nilable(String)).returns(String) }
  def api_example_area_url_html(format, key)
    t = api_example_area_url(format, key || "33", "11", "22", "11", "22")
    t = t.gsub("11", "[latitude]")
    t = t.gsub("22", "[longitude]")
    t = t.sub("33", "[key]") if key.nil?
    htmlify(t)
  end

  sig { params(format: String, key: T.nilable(String)).returns(String) }
  def api_example_authority_url_html(format, key)
    t = api_example_authority_url(format, key || "22", "11")
    t = t.sub("11", "[name]")
    t = t.sub("22", "[key]") if key.nil?
    htmlify(t)
  end

  sig { params(format: String, key: T.nilable(String)).returns(String) }
  def api_example_postcode_url_html(format, key)
    t = api_example_postcode_url(format, key || "22", "11")
    t = t.sub("11", "[postcode]")
    t = t.sub("22", "[key]") if key.nil?
    htmlify(t)
  end

  sig { params(format: String, key: T.nilable(String)).returns(String) }
  def api_example_suburb_state_and_postcode_url_html(format, key)
    t = api_example_suburb_state_and_postcode_url(format, key || "44", "11", "22", "33")
    t = t.sub("11", "[suburb]")
    t = t.sub("22", "[state]")
    t = t.sub("33", "[postcode]")
    t = t.sub("44", "[key]") if key.nil?
    htmlify(t)
  end
end
