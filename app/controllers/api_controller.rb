# typed: strict
# frozen_string_literal: true

class ApiController < ApplicationController
  extend T::Sig

  before_action :check_api_parameters, except: %i[howto]
  before_action :require_api_key, except: %i[howto]
  before_action :authenticate_bulk_api, only: %i[all date_scraped]

  # This is disabled because at least one commercial user of the API is doing
  # GET requests for JSONP instead of using XHR
  # TODO: Remove this line to re-enable CSRF protection on API actions
  skip_before_action :verify_authenticity_token,
                     only: %i[authority suburb_postcode point area date_scraped all]

  class AuthorityParams < T::Struct
    const :authority_id, String
  end

  sig { void }
  def authority
    typed_params = TypedParams[AuthorityParams].new.extract!(params)
    # TODO: Handle the situation where the authority name isn't found
    authority = Authority.find_short_name_encoded!(typed_params.authority_id)
    apps = authority.applications.with_current_version.order("date_scraped DESC")
    api_render(apps, "Recent applications from #{authority.full_name_and_state}")
  end

  class SuburbPostcodeParams < T::Struct
    const :suburb, T.nilable(String)
    const :state, T.nilable(String)
    const :postcode, T.nilable(String)
  end

  sig { void }
  def suburb_postcode
    typed_params = TypedParams[SuburbPostcodeParams].new.extract!(params)
    apps = Application.with_current_version.order("date_scraped DESC")
    descriptions = []
    if typed_params.suburb
      descriptions << typed_params.suburb
      apps = apps.where(application_versions: { suburb: typed_params.suburb })
    end
    if typed_params.state
      descriptions << typed_params.state
      apps = apps.where(application_versions: { state: typed_params.state })
    end
    # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
    if typed_params.postcode
      descriptions << typed_params.postcode
      apps = apps.where(application_versions: { postcode: typed_params.postcode })
    end
    api_render(apps, "Recent applications in #{descriptions.join(', ')}")
  end

  class PointParams < T::Struct
    const :radius, T.nilable(Float)
    const :area_size, T.nilable(Float)
    const :address, T.nilable(String)
    const :lat, T.nilable(Float)
    const :lng, T.nilable(Float)
  end

  sig { void }
  def point
    typed_params = TypedParams[PointParams].new.extract!(params)
    radius = typed_params.radius || typed_params.area_size || 2000.0
    address = typed_params.address
    # Search by address in the API is deprecated. See
    # https://github.com/openaustralia/planningalerts/issues/1356
    # TODO: Remove this as soon as nobody is using it anymore or a
    # date has passed that we've set
    if address
      location = GoogleGeocodeService.call(address).top
      if location.nil?
        render_error("could not geocode address", :bad_request)
        return
      end
      location_text = location.full_address
    else
      location = Location.new(lat: typed_params.lat.to_f, lng: typed_params.lng.to_f)
      location_text = location.to_s
    end
    api_render(
      Application.with_current_version.order("date_scraped DESC").near(
        [location.lat, location.lng], radius / 1000,
        units: :km,
        latitude: "application_versions.lat",
        longitude: "application_versions.lng"
      ),
      "Recent applications within #{help.meters_in_words(radius)} of #{location_text}"
    )
  end

  class AreaParams < T::Struct
    const :bottom_left_lat, Float
    const :bottom_left_lng, Float
    const :top_right_lat, Float
    const :top_right_lng, Float
  end

  sig { void }
  def area
    typed_params = TypedParams[AreaParams].new.extract!(params)
    lat0 = typed_params.bottom_left_lat
    lng0 = typed_params.bottom_left_lng
    lat1 = typed_params.top_right_lat
    lng1 = typed_params.top_right_lng
    api_render(
      Application.with_current_version.order("date_scraped DESC").where("lat > ? AND lng > ? AND lat < ? AND lng < ?", lat0, lng0, lat1, lng1),
      "Recent applications in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
    )
  end

  class DateScrapedParams < T::Struct
    const :date_scraped, String
  end

  sig { void }
  def date_scraped
    typed_params = TypedParams[DateScrapedParams].new.extract!(params)
    begin
      date = Date.parse(typed_params.date_scraped)
    rescue ArgumentError => e
      raise e unless e.message == "invalid date"
    end

    if date
      api_render(Application.with_current_version.order("date_scraped DESC").where("application_versions.date_scraped" => date.beginning_of_day...date.end_of_day), "All applications collected on #{date}")
    else
      render_error("invalid date_scraped", :bad_request)
    end
  end

  class AllParams < T::Struct
    const :since_id, T.nilable(Integer)
  end

  # Note that this returns results in a slightly different format than the
  # other API calls because the paging is done differently (via scrape time rather than page number)
  sig { void }
  def all
    typed_params = TypedParams[AllParams].new.extract!(params)
    # TODO: Check that params page and v aren't being used
    LogApiCallJob.perform_later(
      api_key: request.query_parameters["key"],
      ip_address: request.remote_ip,
      query: request.fullpath,
      params: params.to_h.to_hash,
      user_agent: request.headers["User-Agent"],
      time_as_float: Time.zone.now.to_f
    )
    apps = Application.with_current_version.order("applications.id")
    apps = apps.where("applications.id > ?", typed_params.since_id) if typed_params.since_id

    # Max number of records that we'll show
    limit = 1000

    applications = apps.limit(limit).to_a
    last = applications.last
    last = Application.with_current_version.order("applications.id").last if last.nil?
    max_id = last.id if last

    respond_to do |format|
      format.json do
        @applications = applications
        @max_id = T.let(max_id, T.nilable(Integer))
        render "all", formats: :json
      end
      # Use of the js extension is deprecated. See
      # https://github.com/openaustralia/planningalerts/issues/679
      # TODO: Remove when it's no longer used
      format.js do
        @applications = applications
        @max_id = T.let(max_id, T.nilable(Integer))
        render "all", formats: :json, content_type: Mime[:json]
      end
      # Doesn't make sense (I think) to support georss and geojson here
    end
  end

  sig { void }
  def howto; end

  private

  sig { void }
  def check_api_parameters
    valid_parameter_keys = %w[
      format action controller
      authority_id
      page
      postcode
      suburb state
      address lat lng radius area_size
      bottom_left_lat bottom_left_lng top_right_lat top_right_lng
      count v key since_id date_scraped
    ]

    # Parameter error checking (only do it on the API calls)
    invalid_parameter_keys = params.keys - valid_parameter_keys
    return if invalid_parameter_keys.empty?

    render_error(
      "Bad request: Invalid parameter(s) used: #{invalid_parameter_keys.sort.join(', ')}",
      :bad_request
    )
  end

  class RequireApiKeyParams < T::Struct
    const :key, T.nilable(String)
  end

  sig { void }
  def require_api_key
    typed_params = TypedParams[RequireApiKeyParams].new.extract!(params)
    if typed_params.key && ApiKey.exists?(value: typed_params.key, disabled: false)
      # Everything is fine
      return
    end

    render_error(
      "not authorised - use a valid api key - https://www.openaustraliafoundation.org.au/2015/03/02/planningalerts-api-changes",
      :unauthorized
    )
  end

  sig { params(error_text: String, status: Symbol).void }
  def render_error(error_text, status)
    respond_to do |format|
      format.json do
        render json: { error: error_text }, status: status
      end
      # Use of the js extension is deprecated. See
      # https://github.com/openaustralia/planningalerts/issues/679
      # TODO: Remove when it's no longer used
      format.js do
        render json: { error: error_text }, status: status, content_type: Mime[:json]
      end
      format.geojson do
        render json: { error: error_text }, status: status
      end
      format.rss do
        render plain: error_text, status: status
      end
    end
  end

  class AuthenticateBulkApiParams < T::Struct
    const :key, String
  end

  sig { void }
  def authenticate_bulk_api
    typed_params = TypedParams[AuthenticateBulkApiParams].new.extract!(params)
    return if ApiKey.exists?(value: typed_params.key, bulk: true)

    render_error("no bulk api access", :unauthorized)
  end

  class PerPageParams < T::Struct
    const :count, T.nilable(Integer)
  end

  sig { returns(Integer) }
  def per_page
    typed_params = TypedParams[PerPageParams].new.extract!(params)
    # Allow to set number of returned applications up to a maximum
    count = typed_params.count
    if count && count <= Application.per_page
      count
    else
      Application.per_page
    end
  end

  class ApiRenderParams < T::Struct
    const :page, T.nilable(Integer)
    const :v, T.nilable(String)
  end

  sig { params(apps: Application::RelationType, description: String).void }
  def api_render(apps, description)
    typed_params = TypedParams[ApiRenderParams].new.extract!(params)
    applications = apps.includes(:authority).paginate(page: typed_params.page, per_page: per_page)
    @applications = T.let(applications, T.nilable(T.any(Application::RelationType, T::Array[Application])))
    @description = T.let(description, T.nilable(String))

    LogApiCallJob.perform_later(
      api_key: request.query_parameters["key"],
      ip_address: request.remote_ip,
      query: request.fullpath,
      params: params.to_h.to_hash,
      user_agent: request.headers["User-Agent"],
      time_as_float: Time.zone.now.to_f
    )
    # In Rails 6.0 variants seem to not be able to be a string
    variants = :v2 if typed_params.v == "2"

    respond_to do |format|
      # TODO: Move the template over to using an xml builder
      format.rss do
        render "index", format: :rss,
                        layout: false,
                        content_type: Mime[:xml]
      end
      format.json do
        # TODO: Document use of v parameter
        render "index", formats: :json,
                        variants: variants
      end
      # Use of the js extension is deprecated. See
      # https://github.com/openaustralia/planningalerts/issues/679
      # TODO: Remove when it's no longer used
      format.js do
        # TODO: Document use of v parameter
        render "index", formats: :json,
                        content_type: Mime[:json],
                        variants: variants
      end
      format.geojson do
        render "index"
      end
    end
  end

  sig { returns(ApiController::Helper) }
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ApplicationHelper
    include ActionView::Helpers::TextHelper
  end
end
