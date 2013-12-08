require 'will_paginate/array'

class ApplicationsController < ApplicationController
  def index
    valid_parameter_keys = [
      "format", "action", "controller",
      "authority_id",
      "page", "style",
      "postcode",
      "suburb", "state",
      "address", "lat", "lng", "radius", "area_size",
      "bottom_left_lat", "bottom_left_lng", "top_right_lat", "top_right_lng",
      "callback", "count", "v"]
    
    # TODO: Fix this hacky ugliness
    if request.format == Mime::HTML
      per_page = 30
    else
      # Parameter error checking (only do it on the API calls)
      invalid_parameter_keys = params.keys - valid_parameter_keys
      unless invalid_parameter_keys.empty?
        render :text => "Bad request: Invalid parameter(s) used: #{invalid_parameter_keys.sort.join(', ')}", :status => 400
        return
      end
      per_page = Application.per_page
    end

    # Allow to set number of returned applications up to a maximum
    if params[:count] && params[:count].to_i <= per_page
      per_page = params[:count].to_i
    end
    
    @description = "Recent applications"
    # Don't want the RSS feed to match the paging
    if params[:authority_id]
      # Provide a prettier form of the rss url
      @rss = authority_applications_url(params.merge(:format => "rss", :page => nil))
    else
      @rss = applications_url(params.merge(:format => "rss", :page => nil))
    end

    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
      apps = @authority.applications
      @description << " from #{@authority.full_name_and_state}"
    elsif params[:postcode]
      # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
      apps = Application.where(:postcode => params[:postcode])
      @description << " in postcode #{params[:postcode]}"
    elsif params[:suburb]
      if params[:state]
        apps = Application.where(:suburb => params[:suburb], :state => params[:state])
        @description << " in #{params[:suburb]}, #{params[:state]}"
      else
        apps = Application.where(:suburb => params[:suburb])
        @description << " in #{params[:suburb]}"
      end
    elsif params[:address] || (params[:lat] && params[:lng])
      radius = params[:radius] || params[:area_size] || 2000
      if params[:address]
        location = Location.geocode(params[:address])
        location_text = location.full_address
      else
        location = Location.new(params[:lat].to_f, params[:lng].to_f)
        location_text = location.to_s
      end
      @description << " within #{help.meters_in_words(radius.to_i)} of #{location_text}"
      apps = Application.near([location.lat, location.lng], radius.to_f / 1000, :units => :km)
    elsif params[:bottom_left_lat] && params[:bottom_left_lng] && params[:top_right_lat] && params[:top_right_lng]
      lat0, lng0 = params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f
      lat1, lng1 = params[:top_right_lat].to_f, params[:top_right_lng].to_f
      @description << " in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
      apps = Application.where('lat > ? AND lng > ? AND lat < ? AND lng < ?', lat0, lng0, lat1, lng1)
    else
      @description << " within the last #{Application.nearby_and_recent_max_age_months} months"
      apps = Application.where("date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    end

    @applications = apps.paginate(:page => params[:page], :per_page => per_page)

    respond_to do |format|
      format.html
      # TODO: Move the template over to using an xml builder
      format.rss do
        #ApiStatistic.log(request)
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

  # JSON api for returning the number of scraped applications per day
  def per_day
    authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render :json => authority.applications_per_day
      end
    end
  end

  def per_week
    authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render :json => authority.applications_per_week
      end
    end
  end
  
  def address
    @q = params[:q]
    @radius = params[:radius] || 2000
    @sort = params[:sort] || 'time'
    per_page = 30
    if @q
      location = Location.geocode(@q)
      if location.error
        @other_addresses = []
        @error = "Address #{location.error}"
      else
        @q = location.full_address
        @alert = Alert.new(:address => @q)
        @other_addresses = location.all[1..-1].map{|l| l.full_address}
        @applications = case @sort
                        when 'distance'
                          Application.near([location.lat, location.lng], @radius.to_f / 1000, :units => :km).reorder('distance').paginate(:page => params[:page], :per_page => per_page)
                        else # date_scraped
                          Application.near([location.lat, location.lng], @radius.to_f / 1000, :units => :km).paginate(:page => params[:page], :per_page => per_page)
                        end
        @rss = applications_path(:format => 'rss', :address => @q, :radius => @radius)
      end
    end
    @set_focus_control = "q"
  end
  
  def search
    # TODO: Fix this hacky ugliness
    if request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end

    @q = params[:q]
    @applications = Application.search @q, :order => :date_scraped, :sort_mode => :desc, :page => params[:page], :per_page => per_page if @q
    @rss = search_applications_path(:format => "rss", :q => @q, :page => nil) if @q
    @description = @q ? "Search: #{@q}" : "Search"

    respond_to do |format|
      format.html
      format.rss { render "index", :format => :rss, :layout => false, :content_type => Mime::XML }
    end
  end
  
  def show
    # First check if there is a redirect
    redirect = ApplicationRedirect.find_by_application_id(params[:id])
    if redirect
      redirect_to :id => redirect.redirect_application_id
      return
    end

    @application = Application.find(params[:id])
    @nearby_count = @application.find_all_nearest_or_recent.count
    @comment = Comment.new
    # Required for new email alert signup form
    @alert = Alert.new(:address => @application.address)

    respond_to do |format|
      format.html
    end
  end
  
  def nearby
    # First check if there is a redirect
    redirect = ApplicationRedirect.find_by_application_id(params[:id])
    if redirect
      redirect_to :id => redirect.redirect_application_id
      return
    end

    @sort = params[:sort]
    @rss = nearby_application_url(params.merge(:format => "rss", :page => nil))
    
    # TODO: Fix this hacky ugliness
    if request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end

    application = Application.find(params[:id])
    @description = "Other applications in the last #{application.nearby_and_recent_max_age_months} months within #{application.nearby_and_recent_max_distance_km} km of #{application.address}" 
    case(@sort)
    when "time"
      @applications = application.find_all_nearest_or_recent.paginate :page => params[:page], :per_page => per_page
    when "distance"
      @applications = Application.unscoped do
        application.find_all_nearest_or_recent.paginate :page => params[:page], :per_page => per_page
      end
    else
      redirect_to :sort => "time"
      return
    end

    respond_to do |format|
      format.html { render "nearby" }
      format.rss { render "index", :format => :rss, :layout => false, :content_type => Mime::XML }
    end
  end

  private
  
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ApplicationHelper
  end
end
