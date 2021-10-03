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

  sig { returns(T::Array[OpenStruct]) }
  def items
    @items = T.let(@items, T.nilable(T::Array[OpenStruct]))
    @items ||= feed.map do |tweet|
      OpenStruct.new(
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
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_OAUTH_TOKEN"]
      config.access_token_secret = ENV["TWITTER_OAUTH_TOKEN_SECRET"]
    end
  end
end
