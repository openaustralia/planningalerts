class ApplicationsController < ApplicationController
  def index
    @description = "Recent applications"
    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      authority = Authority.find_by_short_name_encoded(params[:authority_id])
      @applications = authority.applications(:order => "date_scraped DESC", :limit => 100)
      @description << " within #{authority.full_name}"
    elsif params[:postcode]
      # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
      @applications = Application.find_all_by_postcode(params[:postcode], :limit => 100)
      @description << " within postcode #{params[:postcode]}"
    elsif params[:suburb]
      if params[:state]
        @applications = Application.find_all_by_suburb_and_state(params[:suburb], params[:state], :limit => 100)
        @description << " within #{params[:suburb]}, #{params[:state]}"
      else
        @applications = Application.find_all_by_suburb(params[:suburb], :limit => 100)
        @description << " within #{params[:suburb]}"
      end
    else
      if params[:area_size]
        if params[:address]
          location = Location.geocode(params[:address])
          location_text = params[:address]
        elsif params[:lat] && params[:lng]
          location = Location.new(params[:lat].to_f, params[:lng].to_f)
          location_text = location.to_s
        else
          raise "unexpected parameters"
        end
        search_area = Area.centre_and_size(location, params[:area_size].to_i)
        @description << " within #{help.meters_in_words(params[:area_size].to_i)} of #{location_text}"
        @applications = Application.within(search_area).find(:all, :order => "date_scraped DESC", :limit => 100)
      elsif params[:bottom_left_lat] && params[:bottom_left_lng] && params[:top_right_lat] && params[:top_right_lng]
        lower_left = Location.new(params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f)
        upper_right = Location.new(params[:top_right_lat].to_f, params[:top_right_lng].to_f)
        search_area = Area.lower_left_and_upper_right(lower_left, upper_right)
        @description << " within the area (#{lower_left}) (#{upper_right})"
        @applications = Application.within(search_area).find(:all, :order => "date_scraped DESC", :limit => 100)
      else
        @applications = Application.find(:all, :order => "date_scraped DESC", :limit => 100)
      end
    end
    respond_to do |format|
      format.html
      # TODO: Move the template over to using an xml builder
      format.rss { render "index.rss", :layout => false, :content_type => Mime::XML }
    end
  end
  
  def show
    @application = Application.find(params[:id])
    @page_title = @application.address
    
    # TODO: Display date received and date scraped
    
    # Find other applications nearby (within 10km area)
    @nearby_distance = 10000
    search_area = Area.centre_and_size(@application.location, @nearby_distance)
    @nearby_applications = Application.within(search_area).find(:all, :order => "date_scraped DESC", :limit => 10)
    # Don't include the current application
    @nearby_applications.delete(@application)
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
