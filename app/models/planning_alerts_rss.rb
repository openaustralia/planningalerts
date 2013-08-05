class PlanningAlertsRSS

  URL = "http://www.openaustraliafoundation.org.au/category/projects/planningalerts-org-au/feed/"

  def self.recent
    begin
      content = HTTParty.get(URL).body
      feed    = RSS::Parser.parse(content, false)
      feed.channel.items[0...4] # just use the first five items
    rescue # TODO rescue a particular exception
      # This happens when the DB is empty
      []
    end
  end

end
