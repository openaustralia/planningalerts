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
    v1 = params[:feed]["lodgement_date_start(1i)"]
    v2 = params[:feed]["lodgement_date_start(2i)"]
    v3 = params[:feed]["lodgement_date_start(3i)"]
    if v1.present? && v2.present? && v3.present?
      lodgement_date_start = Date.new(v1.to_i, v2.to_i, v3.to_i)
    end
    v1 = params[:feed]["lodgement_date_end(1i)"]
    v2 = params[:feed]["lodgement_date_end(2i)"]
    v3 = params[:feed]["lodgement_date_end(3i)"]
    if v1.present? && v2.present? && v3.present?
      lodgement_date_end = Date.new(v1.to_i, v2.to_i, v3.to_i)
    end
    feed = Feed.new(:base_url => params[:feed][:base_url], :page => params[:feed][:page].to_i,
      :postcode => (params[:feed][:postcode] if params[:feed][:postcode].present?),
      :lodgement_date_start => lodgement_date_start, :lodgement_date_end => lodgement_date_end)
    redirect_to atdis_test_url(:url => feed.url)
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
