class ApplicationsController < ApplicationController
  before_filter :mobile_optimise_switching, :only => [:show, :index, :nearby]
  
  def index
    # TODO: Fix this hacky ugliness
    if in_mobile_view?
      per_page = 10
    elsif request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end
    
    @description = "Recent applications"
    # Don't want the RSS feed to match the paging
    @rss = applications_url(params.merge(:format => "rss", :page => nil))
    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      authority = Authority.find_by_short_name_encoded(params[:authority_id])
      # In production environment raising RecordNotFound will produce an error code 404
      raise ActiveRecord::RecordNotFound if authority.nil?
      @applications = authority.applications.paginate :page => params[:page], :per_page => per_page
      @description << " in #{authority.full_name_and_state}"
    elsif params[:postcode]
      # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
      @applications = Application.paginate :conditions => {:postcode => params[:postcode]},
        :page => params[:page], :per_page => per_page
      @description << " in postcode #{params[:postcode]}"
    elsif params[:suburb]
      if params[:state]
        @applications = Application.paginate :conditions => {:suburb => params[:suburb], :state => params[:state]},
          :page => params[:page], :per_page => per_page
        @description << " in #{params[:suburb]}, #{params[:state]}"
      else
        @applications = Application.paginate :conditions => {:suburb => params[:suburb]},
          :page => params[:page], :per_page => per_page
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
      # TODO: More concise form using chained scope doesn't work
      # http://www.binarylogic.com/2010/01/09/using-geokit-with-searchlogic/ might provide the answer
      @applications = Application.paginate :origin => [location.lat, location.lng], :within => radius.to_f / 1000,
        :page => params[:page], :per_page => per_page
    elsif params[:bottom_left_lat] && params[:bottom_left_lng] && params[:top_right_lat] && params[:top_right_lng]
      lat0, lng0 = params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f
      lat1, lng1 = params[:top_right_lat].to_f, params[:top_right_lng].to_f
      @description << " in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
      @applications = Application.paginate :bounds => [[lat0, lng0], [lat1, lng1]],
        :page => params[:page], :per_page => per_page
    else
      @applications = Application.paginate :page => params[:page], :per_page => per_page
    end
    @page_title = @description
    respond_to do |format|
      format.html
      format.mobile { render "index_mobile", :layout => "mobile" }
      # TODO: Move the template over to using an xml builder
      format.rss { render "index.rss", :layout => false, :content_type => Mime::XML }
      format.js { render :json => @applications.to_json(:except => [:authority_id, :suburb, :state, :postcode, :distance]) }
    end
  end
  
  def address
    @q = params[:q]
    @radius = params[:radius] || 2000
    per_page = 30
    if @q
      location = Location.geocode(@q)
      if location.error
        @other_addresses = []
        @error = "Address #{location.error}"
      else
        @q = location.full_address
        @other_addresses = location.all[1..-1].map{|l| l.full_address}
        @applications = Application.paginate :origin => [location.lat, location.lng], :within => @radius.to_f / 1000,
          :page => params[:page], :per_page => per_page
      end
    end
  end
  
  def search
    @q = params[:q]
    @page_title = "Search"
    if @q
      @page_title << ": #{@q}"
      @applications = Application.search @q, :order => :date_scraped, :sort_mode => :desc, :page => params[:page]
    end
  end
  
  def show
    @map = true
    @application = Application.find(params[:id])
    @page_title = "#{@application.address} | #{@application.date_scraped.to_date.to_formatted_s(:rfc822)}"
    @meta_description = "Planning application: #{@application.description} Address: #{@application.address}"
    
    # An application that just now been lodged that's 2 km away is about as important as an application that was lodged next door 2 months ago.
    @nearby_applications = @application.find_all_nearest_or_recent[0...5]
    
    respond_to do |format|
      format.html
      format.mobile { render "show_mobile", :layout => "mobile" }
    end
  end
  
  def nearby
    # TODO: Fix this hacky ugliness
    if in_mobile_view?
      per_page = 10
    elsif request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end

    months = 2
    km = 2
    application = Application.find(params[:id])
    # TODO: Make @description and @page_title the same in the view
    @description = "Other applications in the last #{months} months within #{km} km of #{application.address}" 
    @page_title = @description
    @applications = application.find_all_nearest_or_recent(km, months * 4 * 7 * 24 * 60 * 60).paginate :page => params[:page], :per_page => per_page
    respond_to do |format|
      format.html { render "index" }
      format.mobile { render "index_mobile", :layout => "mobile" }
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
