# typed: strict
# frozen_string_literal: true

class ApiController < ApplicationController
  extend T::Sig

  before_action :check_api_parameters
  before_action :require_api_key
  before_action :authenticate_bulk_api, only: %i[all date_scraped]
  before_action :log_api_call
  before_action :update_api_usage

  # This is disabled because at least one commercial user of the API is doing
  # GET requests for JSONP instead of using XHR
  # TODO: Remove this line to re-enable CSRF protection on API actions
  skip_before_action :verify_authenticity_token,
                     only: %i[authority suburb_postcode point area date_scraped all]

  sig { void }
  def authority
    params_authority_id = T.cast(params[:authority_id], String)

    # TODO: Handle the situation where the authority name isn't found
    authority = Authority.find_short_name_encoded!(params_authority_id)
    apps = authority.applications.order(first_date_scraped: :desc)
    api_render(apps, "Recent applications from #{authority.full_name_and_state}")
  end

  sig { void }
  def suburb_postcode
    apps = Application.order(first_date_scraped: :desc)
    descriptions = []
    if params[:suburb]
      descriptions << params[:suburb]
      apps = apps.where(suburb: params[:suburb])
    end
    if params[:state]
      descriptions << params[:state]
      apps = apps.where(state: params[:state])
    end
    # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
    if params[:postcode]
      descriptions << params[:postcode]
      apps = apps.where(postcode: params[:postcode])
    end
    api_render(apps, "Recent applications in #{descriptions.join(', ')}")
  end

  sig { void }
  def point
    params_radius = T.cast(params[:radius], T.nilable(T.any(String, Numeric)))
    params_area_size = T.cast(params[:area_size], T.nilable(T.any(String, Numeric)))
    params_lat = T.cast(params[:lat], T.any(String, Numeric))
    params_lng = T.cast(params[:lng], T.any(String, Numeric))

    radius = if params_radius
               params_radius.to_f
             elsif params_area_size
               params_area_size.to_f
             else
               2000.0
             end
    location = Location.new(lat: params_lat.to_f, lng: params_lng.to_f)
    location_text = location.to_s
    api_render(
      Application.order(first_date_scraped: :desc)
                 .near([location.lat, location.lng], radius / 1000, units: :km),
      "Recent applications within #{help.meters_in_words(radius)} of #{location_text}"
    )
  end

  sig { void }
  def area
    lat0 = params[:bottom_left_lat]
    lng0 = params[:bottom_left_lng]
    lat1 = params[:top_right_lat]
    lng1 = params[:top_right_lng]
    api_render(
      Application.order(first_date_scraped: :desc).where(lat: lat0..lat1, lng: lng0..lng1),
      "Recent applications in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
    )
  end

  sig { void }
  def date_scraped
    params_date_scraped = T.cast(params[:date_scraped], String)

    begin
      date = Date.parse(params_date_scraped)
    rescue ArgumentError => e
      raise e unless e.message == "invalid date"
    end

    if date
      api_render(Application.order("date_scraped DESC").where("date_scraped" => date.beginning_of_day...date.end_of_day), "All applications collected on #{date}")
    else
      render_error("invalid date_scraped", :bad_request)
    end
  end

  # Note that this returns results in a slightly different format than the
  # other API calls because the paging is done differently (via scrape time rather than page number)
  sig { void }
  def all
    # TODO: Check that params page and v aren't being used
    apps = Application.includes(:authority).order(:id)
    apps = apps.where("id > ?", params[:since_id]) if params[:since_id]

    # Max number of records that we'll show
    limit = 10

    applications = apps.limit(limit).to_a
    last = applications.last
    last = Application.order(:id).last if last.nil?
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

  private

  sig { void }
  def check_api_parameters
    valid_parameter_keys = %w[
      format action controller
      authority_id
      page
      postcode
      suburb state
      lat lng radius area_size
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

  sig { void }
  def require_api_key
    if params[:key]
      @current_api_key = T.let(ApiKey.find_by(value: params[:key], disabled: false), T.nilable(ApiKey))
      if @current_api_key
        # Everything is fine
        return
      end
    end

    render_error("not authorised - use a valid api key", :unauthorized)
  end

  sig { void }
  def authenticate_bulk_api
    # This should only be called after require_api_key doesn't error so @current_api_key should always be non-nil
    return if T.must(@current_api_key).bulk?

    render_error("no bulk api access", :unauthorized)
  end

  sig { void }
  def log_api_call
    LogApiCallJob.perform_async(
      request.query_parameters["key"],
      request.remote_ip,
      request.fullpath,
      permitted_params.merge(
        controller: params[:controller],
        action: params[:action],
        format: params[:format]
      ).to_h,
      request.headers["User-Agent"],
      Time.zone.now.to_f
    )
  end

  sig { void }
  def update_api_usage
    # This is doing everything in UTC which means that the "daily" period does *not* start at midnight Australian time which is somewhat
    # confusing. It's not hugely important in the grand scheme of things as the daily usage is more used to see the order of magnitude
    # of usage. The detailed usage of users is capped via the rack middleware which is going to be accurate.
    # TODO: Switch over to using an Australian time zone
    UpdateApiUsageJob.perform_async(T.must(T.must(@current_api_key).id), Time.zone.today.to_s)
  end

  sig { params(error_text: String, status: Symbol).void }
  def render_error(error_text, status)
    respond_to do |format|
      format.json do
        render json: { error: error_text }, status:
      end
      # Use of the js extension is deprecated. See
      # https://github.com/openaustralia/planningalerts/issues/679
      # TODO: Remove when it's no longer used
      format.js do
        render json: { error: error_text }, status:, content_type: Mime[:json]
      end
      format.geojson do
        render json: { error: error_text }, status:
      end
      format.rss do
        render plain: error_text, status:
      end
    end
  end

  sig { returns(Integer) }
  def per_page
    params_count = T.cast(params[:count], T.nilable(T.any(String, Numeric)))

    # Allow to set number of returned applications up to a maximum
    count = params_count&.to_i
    if count && count <= Application.max_per_page
      count
    else
      Application.max_per_page
    end
  end

  sig { params(apps: T.untyped, description: String).void }
  def api_render(apps, description)
    # typed_params = TypedParams[ApiRenderParams].new.extract!(params)
    applications = apps.includes(:authority).page(params[:page]).per(per_page)
    @applications = T.let(applications, T.untyped)
    @description = T.let(description, T.nilable(String))

    # In Rails 6.0 variants seem to not be able to be a string
    variants = :v2 if params[:v] == "2"

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
                        variants:
      end
      # Use of the js extension is deprecated. See
      # https://github.com/openaustralia/planningalerts/issues/679
      # TODO: Remove when it's no longer used
      format.js do
        # TODO: Document use of v parameter
        render "index", formats: :json,
                        content_type: Mime[:json],
                        variants:
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

  sig { returns(T.untyped) }
  def permitted_params
    params.permit(
      :authority_id, :suburb, :state, :postcode, :radius, :area_size,
      :lat, :lng, :bottom_left_lat, :bottom_left_lng, :top_right_lat,
      :top_right_lng, :date_scraped, :since_id, :key, :count, :page, :v
    )
  end
end
