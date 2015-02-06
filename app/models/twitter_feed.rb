class TwitterFeed

  attr_reader :username

  def initialize(username)
    @username = username
  end

  def feed
    if Twitter.credentials?
      # If there's any kind of error just return an empty feed
      begin
        @feed ||= Twitter.user_timeline(username)[0...2] || []
      rescue
        []
      end
    else
      []
    end
  end

  def items
    @items ||= feed.map do |tweet|
      item       = OpenStruct.new
      item.title = tweet.text.html_safe
      item.date  = tweet.created_at
      item.link  = "https://twitter.com/#{username}/status/#{tweet.id}"
      item
    end
  end

end
