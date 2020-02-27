# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :check_api_parameters, except: %i[old_index howto]
  before_action :require_api_key, except: %i[old_index howto]
  before_action :authenticate_bulk_api, only: %i[all date_scraped]

  # This is disabled because at least one commercial user of the API is doing
  # GET requests for JSONP instead of using XHR
  # TODO: Remove this line to re-enable CSRF protection on API actions
  skip_before_action :verify_authenticity_token,
                     only: %i[authority suburb_postcode point area date_scraped all]

  def authority
    # TODO: Handle the situation where the authority name isn't found
    authority = Authority.find_short_name_encoded!(params[:authority_id])
    api_render(authority.applications, "Recent applications from #{authority.full_name_and_state}")
  end

  def suburb_postcode
    apps = Application.with_current_version.order("date_scraped DESC")
    descriptions = []
    if params[:suburb]
      descriptions << params[:suburb]
      apps = apps.where(application_versions: { suburb: params[:suburb] })
    end
    if params[:state]
      descriptions << params[:state]
      apps = apps.where(application_versions: { state: params[:state] })
    end
    # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
    if params[:postcode]
      descriptions << params[:postcode]
      apps = apps.where(application_versions: { postcode: params[:postcode] })
    end
    api_render(apps, "Recent applications in #{descriptions.join(', ')}")
  end

  def point
    radius = params[:radius] || params[:area_size] || 2000
    if params[:address]
      location = GoogleGeocodeService.call(params[:address]).top
      if location.nil?
        render_error("could not geocode address", :bad_request)
        return
      end
      location_text = location.full_address
    else
      location = Location.new(lat: params[:lat].to_f, lng: params[:lng].to_f)
      location_text = location.to_s
    end
    api_render(
      Application.with_current_version.order("date_scraped DESC").near(
        [location.lat, location.lng], radius.to_f / 1000,
        units: :km,
        latitude: "application_versions.lat",
        longitude: "application_versions.lng"
      ),
      "Recent applications within #{help.meters_in_words(radius.to_i)} of #{location_text}"
    )
  end

  def area
    lat0 = params[:bottom_left_lat].to_f
    lng0 = params[:bottom_left_lng].to_f
    lat1 = params[:top_right_lat].to_f
    lng1 = params[:top_right_lng].to_f
    api_render(
      Application.with_current_version.order("date_scraped DESC").where("lat > ? AND lng > ? AND lat < ? AND lng < ?", lat0, lng0, lat1, lng1),
      "Recent applications in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
    )
  end

  def date_scraped
    begin
      date = Date.parse(params[:date_scraped])
    rescue ArgumentError => e
      raise e unless e.message == "invalid date"
    end

    if date
      api_render(Application.with_current_version.order("date_scraped DESC").where("application_versions.date_scraped" => date.beginning_of_day...date.end_of_day), "All applications collected on #{date}")
    else
      render_error("invalid date_scraped", :bad_request)
    end
  end

  # Note that this returns results in a slightly different format than the
  # other API calls because the paging is done differently (via scrape time rather than page number)
  def all
    # TODO: Check that params page and v aren't being used
    LogApiCallJob.perform_later(
      api_key: request.query_parameters["key"],
      ip_address: request.remote_ip,
      query: request.fullpath,
      user_agent: request.headers["User-Agent"],
      time_as_float: Time.zone.now.to_f
    )
    apps = Application.with_current_version.order("applications.id")
    apps = apps.where("applications.id > ?", params["since_id"]) if params["since_id"]

    # Max number of records that we'll show
    limit = 1000

    applications = apps.limit(limit).to_a
    last = applications.last
    last = Application.with_current_version.order("applications.id").last if last.nil?
    max_id = last.id if last

    respond_to do |format|
      format.js do
        s = { applications: applications, application_count: apps.count, max_id: max_id }
        j = s.to_json(only: %i[id council_reference applications application_count max_id],
                      methods: %i[date_scraped address description info_url
                                  comment_url date_received on_notice_from
                                  on_notice_to lat lng],
                      include: { authority: { only: [:full_name] } })
        render json: j, callback: params[:callback], content_type: Mime[:json]
      end
    end
  end

  def old_index
    case params[:call]
    when "address"
      redirect_to applications_url(format: "rss", address: params[:address], radius: params[:area_size])
    when "point"
      redirect_to applications_url(
        format: "rss", lat: params[:lat], lng: params[:lng],
        radius: params[:area_size]
      )
    when "area"
      redirect_to applications_url(
        format: "rss",
        bottom_left_lat: params[:bottom_left_lat], bottom_left_lng: params[:bottom_left_lng],
        top_right_lat: params[:top_right_lat], top_right_lng: params[:top_right_lng]
      )
    when "authority"
      redirect_to authority_applications_url(format: "rss", authority_id: Authority.short_name_encoded(params[:authority]))
    else
      render plain: "unexpected value for parameter call. Accepted values: address, point, area and authority"
    end
  end

  def howto; end

  private

  def ssl_required?
    # Only redirect on howto page. Normal api requests on this controller should not redirect
    params[:action] == "howto" && super
  end

  def check_api_parameters
    valid_parameter_keys = %w[
      format action controller
      authority_id
      page style
      postcode
      suburb state
      address lat lng radius area_size
      bottom_left_lat bottom_left_lng top_right_lat top_right_lng
      callback count v key since_id date_scraped
    ]

    # Parameter error checking (only do it on the API calls)
    invalid_parameter_keys = params.keys - valid_parameter_keys
    return if invalid_parameter_keys.empty?

    render_error(
      "Bad request: Invalid parameter(s) used: #{invalid_parameter_keys.sort.join(', ')}",
      :bad_request
    )
  end

  def require_api_key
    if params[:key] && User.where(api_key: params[:key], api_disabled: false).exists?
      # Everything is fine
      return
    end

    render_error(
      "not authorised - use a valid api key - https://www.openaustraliafoundation.org.au/2015/03/02/planningalerts-api-changes",
      :unauthorized
    )
  end

  def render_error(error_text, status)
    respond_to do |format|
      format.js do
        render json: { error: error_text }, status: status, content_type: Mime[:json]
      end
      format.rss do
        render plain: error_text, status: status
      end
    end
  end

  def authenticate_bulk_api
    return if User.where(api_key: params[:key], bulk_api: true).exists?

    render_error("no bulk api access", :unauthorized)
  end

  def per_page
    # Allow to set number of returned applications up to a maximum
    if params[:count] && params[:count].to_i <= Application.per_page
      params[:count].to_i
    else
      Application.per_page
    end
  end

  def api_render(apps, description)
    @applications = apps.includes(:authority).paginate(page: params[:page], per_page: per_page)
    @description = description

    LogApiCallJob.perform_later(
      api_key: request.query_parameters["key"],
      ip_address: request.remote_ip,
      query: request.fullpath,
      user_agent: request.headers["User-Agent"],
      time_as_float: Time.zone.now.to_f
    )
    respond_to do |format|
      # TODO: Move the template over to using an xml builder
      format.rss do
        render params[:style] == "html" ? "index_html" : "index",
               format: :rss, layout: false, content_type: Mime[:xml]
      end
      format.js do
        # TODO: Document use of v parameter
        s = if params[:v] == "2"
              { application_count: @applications.count, page_count: @applications.total_pages, applications: @applications }
            else
              @applications
            end
        j = s.to_json(only: %i[id council_reference applications application_count page_count],
                      methods: %i[date_scraped address description info_url
                                  comment_url date_received on_notice_from
                                  on_notice_to lat lng],
                      include: { authority: { only: [:full_name] } })
        render json: j, callback: params[:callback], content_type: Mime[:json]
      end
    end
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ApplicationHelper
  end
end
