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
      redirect_to authority_applications_url(:format => "rss", :authority_id => Authority.short_name_encoded(params[:authority]))
    else
      render :text => "unexpected value for parameter call. Accepted values: address, point, area and authority"
    end
  end
  
  def old_howto
    redirect_to :action => :howto
  end
  
  def howto
    @page_title = "API"
  end  
end
