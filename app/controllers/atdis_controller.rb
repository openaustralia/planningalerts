# typed: true
# frozen_string_literal: true

class AtdisController < ApplicationController
  class TestParams < T::Struct
    const :url, T.nilable(String)
  end

  def test
    typed_params = TypedParams[TestParams].new.extract!(params)
    if typed_params.url.present?
      @feed = Feed.create_from_url(typed_params.url)
      begin
        @page = @feed.applications
      rescue RestClient::InternalServerError
        @error = "Remote server returned an internal server error (error code 500) accessing #{typed_params.url}"
      rescue RestClient::RequestTimeout
        @error = "Timeout in request to #{typed_params.url}. Remote server did not respond in a reasonable amount of time."
      rescue RestClient::Exception => e
        @error = "Could not load data - #{e}"
      rescue URI::InvalidURIError
        @error = "The url appears to be invalid #{typed_params.url}"
      end
    else
      @feed = Feed.new
    end
  end

  class FeedParams < T::Struct
    const :base_url, String
    const :page, Integer
    const :lodgement_date_start, T.nilable(Date)
    const :lodgement_date_end, T.nilable(Date)
    const :last_modified_date_start, T.nilable(Date)
    const :last_modified_date_end, T.nilable(Date)
    const :street, T.nilable(String)
    const :suburb, T.nilable(String)
    const :postcode, T.nilable(String)
  end

  class TestRedirectParams < T::Struct
    const :feed, FeedParams
  end

  # The job here is to take ugly posted parameters and redirect to a much simpler url
  def test_redirect
    typed_params = TypedParams[TestRedirectParams].new.extract!(params)
    @feed = Feed.new(typed_params.feed.serialize.symbolize_keys)
    if @feed.valid?
      redirect_to atdis_test_url(url: @feed.url)
    else
      render "test"
    end
  end

  class ExampleFeedParams < T::Struct
    const :number, Integer
    const :page, T.nilable(Integer)
  end

  def feed
    typed_params = TypedParams[ExampleFeedParams].new.extract!(params)
    file = Feed.example_path(typed_params.number, typed_params.page || 1)
    if File.exist?(file)
      render file: file, content_type: Mime[:json], layout: false
    else
      render plain: "not available", status: :not_found
    end
  end

  def specification; end
end
