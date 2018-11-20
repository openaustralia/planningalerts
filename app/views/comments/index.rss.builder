# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:georss" => "http://www.georss.org/georss" do
  xml.channel do
    xml.title "Recent comments | PlanningAlerts"
    xml.description "Recent comments made on development applications via PlanningAlerts"
    xml.link root_url

    @comments.each do |comment|
      xml.item do
        xml.title "Comment on application #{comment.application.council_reference} at #{comment.application.address} by #{comment.name}"
        xml.description comment.text
        xml.pubDate comment.updated_at.to_s(:rfc822)
        xml.link application_url(comment.application, anchor: "comment#{comment.id}")
        xml.guid application_url(comment.application, anchor: "comment#{comment.id}")
        xml.georss :featurename, comment.application.address
        xml.georss :point, "#{comment.application.lat} #{comment.application.lng}"
      end
    end
  end
end
