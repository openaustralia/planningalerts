class PlanningAlertsRSS
  URL = "https://www.openaustraliafoundation.org.au/category/projects/planningalerts-org-au/feed/".freeze

  def self.recent
    content = HTTParty.get(URL).body
    feed    = RSS::Parser.parse(content, false)
    feed.channel.items[0...6] # just use the first 6 items
  rescue SocketError, Errno::ETIMEDOUT, RSS::NotWellFormedError
    []
  end
end
