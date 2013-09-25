class AtdisController < ApplicationController
  def test
    @url = params[:url]
    if !@url.blank?
      u = URI.parse(@url)
      u2 = URI.parse(atdis_feed_url(:number => 1))
      p = Rails.application.routes.recognize_path(u.path)
      # In development we don't have a multithreaded web server so we have to fake the serving of the data
      # This is icky. Make this less icky.
      if Rails.env.development? && u.host == u2.host && u.port == u2.port && p[:controller] == "atdis" && p[:action] == "feed"
        number = p[:number].to_i
        if u.query.nil? || u.query == "page=1"
          page = 1
        elsif u.query == "page=2"
          page = 2
        end
        file = example_path(number, page)
        j = File.read(file)
        page = ATDIS::Page.read_json(j)
        page.url = @url
      else
        page = ATDIS::Page.read_url(@url)
      end
      @page_object = page
    end
  end

  def feed
    page = (params[:page] || "1").to_i
    number = params[:number].to_i
    render :file  => example_path(number, page), :content_type => "text/javascript", :layout => false
  end

  def specification
  end

  private

  def example_path(number, page)
    Rails.root.join("spec/atdis_json_examples/example#{number}_page#{page}.json")
  end
end
