class ApiController < ApplicationController
  caches_page :howto
  before_filter :check_api_parameters, except: [:old_index, :howto]

  def authority
    # TODO Handle the situation where the authority name isn't found
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @description = "Recent applications from #{@authority.full_name_and_state}"
    api_render(@authority.applications)
  end

  def postcode
    # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
    @description = "Recent applications in postcode #{params[:postcode]}"
    api_render(Application.where(:postcode => params[:postcode]))
  end

  def suburb
    apps = Application.where(:suburb => params[:suburb])
    @description = "Recent applications in #{params[:suburb]}"
    if params[:state]
      @description += ", #{params[:state]}"
      apps = apps.where(:state => params[:state])
    end
    api_render(apps)
  end

  def point
    radius = params[:radius] || params[:area_size] || 2000
    if params[:address]
      location = Location.geocode(params[:address])
      location_text = location.full_address
    else
      location = Location.new(params[:lat].to_f, params[:lng].to_f)
      location_text = location.to_s
    end
    @description = "Recent applications within #{help.meters_in_words(radius.to_i)} of #{location_text}"
    api_render(Application.near([location.lat, location.lng], radius.to_f / 1000, :units => :km))
  end

  def area
    lat0, lng0 = params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f
    lat1, lng1 = params[:top_right_lat].to_f, params[:top_right_lng].to_f
    @description = "Recent applications in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
    api_render(Application.where('lat > ? AND lng > ? AND lat < ? AND lng < ?', lat0, lng0, lat1, lng1))
  end

  def all
    @description = "Recent applications within the last #{Application.nearby_and_recent_max_age_months} months"
    apps = Application.where("date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    @applications = apps.paginate(:page => params[:page], :per_page => per_page)

    respond_to do |format|
      # TODO: Move the template over to using an xml builder
      format.rss do
        #ApiStatistic.log(request)
        if ApiKey.where(key: params[:key]).exists?
          render params[:style] == "html" ? "index_html" : "index",
            :format => :rss, :layout => false, :content_type => Mime::XML
        else
          render xml: {error: "not authorised"}, status: 401
        end
      end
      format.js do
        #ApiStatistic.log(request)
        if params[:v] == "2"
          s = {:applications => @applications, :application_count => @applications.count, :page_count => @applications.total_pages}
        else
          s = @applications
        end
        j = s.to_json(:except => [:authority_id, :suburb, :state, :postcode, :distance],
          :include => {:authority => {:only => [:full_name]}})
        if ApiKey.where(key: params[:key]).exists?
          render :json => j, :callback => params[:callback]
        else
          render json: {error: "not authorised"}, status: 401
        end
      end
    end
  end

  def old_index
    case params[:call]
    when "address"
      redirect_to applications_url(:format => "rss", :address => params[:address], :radius => params[:area_size])
    when "point"
      redirect_to applications_url(:format => "rss", :lat => params[:lat], :lng => params[:lng],
        :radius => params[:area_size])
    when "area"
      redirect_to applications_url(:format => "rss",
        :bottom_left_lat => params[:bottom_left_lat], :bottom_left_lng => params[:bottom_left_lng],
        :top_right_lat => params[:top_right_lat], :top_right_lng => params[:top_right_lng])
    when "authority"
      redirect_to authority_applications_url(:format => "rss", :authority_id => Authority.short_name_encoded(params[:authority]))
    else
      render :text => "unexpected value for parameter call. Accepted values: address, point, area and authority"
    end
  end

  def howto
  end

  private

  def check_api_parameters
    valid_parameter_keys = [
      "format", "action", "controller",
      "authority_id",
      "page", "style",
      "postcode",
      "suburb", "state",
      "address", "lat", "lng", "radius", "area_size",
      "bottom_left_lat", "bottom_left_lng", "top_right_lat", "top_right_lng",
      "callback", "count", "v", "key"]

    # Parameter error checking (only do it on the API calls)
    invalid_parameter_keys = params.keys - valid_parameter_keys
    unless invalid_parameter_keys.empty?
      render :text => "Bad request: Invalid parameter(s) used: #{invalid_parameter_keys.sort.join(', ')}", :status => 400
    end
  end

  def per_page
    # Allow to set number of returned applications up to a maximum
    if params[:count] && params[:count].to_i <= Application.per_page
      params[:count].to_i
    else
      Application.per_page
    end
  end

  # TODO don't use instance variables
  def api_render(apps)
    @applications = apps.paginate(:page => params[:page], :per_page => per_page)

    respond_to do |format|
      # TODO: Move the template over to using an xml builder
      format.rss do
        render params[:style] == "html" ? "index_html" : "index",
          :format => :rss, :layout => false, :content_type => Mime::XML
      end
      format.js do
        #ApiStatistic.log(request)
        if params[:v] == "2"
          s = {:applications => @applications, :application_count => @applications.count, :page_count => @applications.total_pages}
        else
          s = @applications
        end
        j = s.to_json(:except => [:authority_id, :suburb, :state, :postcode, :distance],
          :include => {:authority => {:only => [:full_name]}})
        render :json => j, :callback => params[:callback]
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
