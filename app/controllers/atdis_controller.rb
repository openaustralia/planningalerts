class AtdisController < ApplicationController
  def test
    if !params[:url].blank?
      @feed = Feed.create_from_url(params[:url])
      begin
        @page = @feed.applications
      rescue RestClient::ResourceNotFound => e
        @error = "Could not load data - #{e}"
      end
    else
      @feed = Feed.new
    end
  end

  # The job here is to take ugly posted parameters and redirect to a much simpler url
  def test_redirect
    feed = Feed.new(
      :base_url => params[:feed][:base_url],
      :page => params[:feed][:page],
      :postcode => params[:feed][:postcode],
      :lodgement_date_start => params[:feed][:lodgement_date_start],
      :lodgement_date_end => params[:feed][:lodgement_date_end],
      :last_modified_date_start => params[:feed][:last_modified_date_start],
      :last_modified_date_end => params[:feed][:last_modified_date_end]
    )
    redirect_to atdis_test_url(:url => feed.url)
  end

  def feed
    file = Feed.example_path(params[:number].to_i, (params[:page] || "1").to_i)
    if File.exists?(file)
      render :file  => file, :content_type => "text/javascript", :layout => false
    else
      render :text => "not available", :status => 404
    end
  end

  def specification
  end
end
