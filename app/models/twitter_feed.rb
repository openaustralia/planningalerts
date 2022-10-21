# typed: strict
# frozen_string_literal: true

class TwitterFeed
  extend T::Sig

  sig { returns(String) }
  attr_reader :username

  sig { returns(Logger) }
  attr_reader :logger

  sig { params(username: String, logger: Logger).void }
  def initialize(username, logger)
    @username = username
    @logger = logger
  end

  sig { returns(T::Array[Twitter::Tweet]) }
  def feed
    twitter = client
    if twitter.nil?
      logger.warn "No twitter API credentials set"
      return []
    end

    # If there's any kind of error just return an empty feed
    begin
      @feed = T.let(@feed, T.nilable(T::Array[Twitter::Tweet]))
      @feed ||= twitter.user_timeline(username)[0...2] || []
    rescue StandardError => e
      logger.error "while accessing twitter API: #{e}"
      []
    end
  end

  class Item < T::Struct
    const :title, String
    # TODO: Use this right for the string here?
    const :date, String
    const :link, String
  end

  sig { returns(T::Array[Item]) }
  def items
    @items = T.let(@items, T.nilable(T::Array[Item]))
    @items ||= feed.map do |tweet|
      Item.new(
        title: tweet.text,
        date: tweet.created_at,
        link: "https://twitter.com/#{username}/status/#{tweet.id}"
      )
    end
  end

  sig { returns(T.nilable(Twitter::REST::Client)) }
  def client
    return unless ENV["TWITTER_CONSUMER_KEY"]

    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch("TWITTER_CONSUMER_KEY", nil)
      config.consumer_secret     = ENV.fetch("TWITTER_CONSUMER_SECRET", nil)
      config.access_token        = ENV.fetch("TWITTER_OAUTH_TOKEN", nil)
      config.access_token_secret = ENV.fetch("TWITTER_OAUTH_TOKEN_SECRET", nil)
    end
  end
end
