class AtdisController < ApplicationController
  def test
    if !params[:url].blank?
      feed_options = ATDIS::Feed.options_from_url(params[:url])
      base_url = ATDIS::Feed.base_url_from_url(params[:url])

      @feed = Feed.new(:base_url => base_url, :page => feed_options[:page], :postcode => feed_options[:postcode])

      u = URI.parse(@feed.base_url)
      # In development we don't have a multithreaded web server so we have to fake the serving of the data
      # Assume if the url is local it's actually for one of the test data sets. We could be more careful but
      # there is little point.
      if Rails.env.development? && u.host == "localhost"
        file = example_path(Rails.application.routes.recognize_path(u.path)[:number].to_i, @feed.page)
        if File.exists?(file)
          @page = ATDIS::Page.read_json(File.read(file))
          @page.url = @feed.url
        else
          @error = "That example data does not exist"
        end
      else
        begin
          @page = @feed.applications
        rescue RestClient::ResourceNotFound => e
          # TODO Show some kind of error message
          @error = "Could not load data - #{e}"
        end
      end
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

  private

  def example_path(number, page)
    Rails.root.join("spec/atdis_json_examples/example#{number}_page#{page}.json")
  end
end
