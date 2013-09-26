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
    feed = ATDIS::Feed.new(params[:feed][:base_url])
    options = {}
    options[:page] = params[:feed][:page] if params[:feed][:page].present? && params[:feed][:page] != "1"
    options[:postcode] = params[:feed][:postcode] if params[:feed][:postcode].present?
    redirect_to atdis_test_url(:url => feed.url(options))
  end

  def feed
    file = example_path(params[:number].to_i, (params[:page] || "1").to_i)
    if File.exists?(file)
      render :file  => file, :content_type => "text/javascript", :layout => false
    else
      render :text => "not available", :status => 404
    end
  end

  def specification
  end

end
