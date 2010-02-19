class ApiController < ApplicationController
  caches_page :howto

  def old_index
    case params[:call]
    when "address"
      redirect_to applications_url(:format => "rss", :address => params[:address], :area_size => params[:area_size])
    when "point"
      redirect_to applications_url(:format => "rss", :lat => params[:lat], :lng => params[:lng],
        :area_size => params[:area_size])
    when "area"
      redirect_to applications_url(:format => "rss",
        :bottom_left_lat => params[:bottom_left_lat], :bottom_left_lng => params[:bottom_left_lng],
        :top_right_lat => params[:top_right_lat], :top_right_lng => params[:top_right_lng])
    when "authority"
      redirect_to api_url(:call => "authority", :authority => params[:authority])
    else
      raise "unexpected value for :call"
    end
  end
  
  def index
    # TODO: Move the template over to using an xml builder
    if params[:call] == "authority"
      # TODO Handle the situation where the authority name isn't found
      authority = Authority.find_by_short_name(params[:authority])
      @applications = authority.applications(:order => "date_scraped DESC", :limit => 100)
    else
      raise "unexpected value for :call"
    end
    render "shared/applications.rss", :layout => false, :content_type => Mime::XML
  end
  
  def old_howto
    redirect_to :action => :howto
  end
  
  def howto
    @page_title = "API"
  end  
end
