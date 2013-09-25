class AtdisController < ApplicationController
  def test
    @url = params[:url]
    @page = (params[:page] || "1").to_i
    @postcode = params[:postcode]

    if !@url.blank?
      @feed = ATDIS::Feed.new(@url)
      feed_options = {:page => @page}
      feed_options.delete(:page) if feed_options[:page] == 1
      feed_options[:postcode] = @postcode unless @postcode.blank?

      u = URI.parse(@url)
      u2 = URI.parse(atdis_feed_url(:number => 1))
      p = Rails.application.routes.recognize_path(u.path)
      # In development we don't have a multithreaded web server so we have to fake the serving of the data
      # This is icky. Make this less icky.
      if Rails.env.development? && u.host == u2.host && u.port == u2.port && p[:controller] == "atdis" && p[:action] == "feed"
        file = example_path(p[:number].to_i, @page)
        if File.exists?(file)
          page = ATDIS::Page.read_json(File.read(file))
          page.url = @feed.url(feed_options)
        else
          page = nil
        end
      else
        page = @feed.applications(feed_options)
      end
      @page_object = page
    end
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
