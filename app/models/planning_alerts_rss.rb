class PlanningAlertsRSS

  URL = "https://www.openaustraliafoundation.org.au/category/projects/planningalerts-org-au/feed/"

  def self.recent
    begin
      content = HTTParty.get(URL).body
      feed    = RSS::Parser.parse(content, false)
      feed.channel.items[0...6] # just use the first 6 items
    rescue SocketError, Errno::ETIMEDOUT
      []
    end
  end

end
