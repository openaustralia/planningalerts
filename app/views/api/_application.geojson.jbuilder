# typed: strict
# frozen_string_literal: true

json.type "Feature"
json.geometry do
  json.type "Point"
  json.coordinates [application.lng, application.lat]
end
json.properties do
  json.id application.id
  json.council_reference application.council_reference
  json.date_scraped application.first_date_scraped
  json.address application.address
  json.description application.description
  json.info_url application.info_url
  # Provided for backwards compatibility
  json.comment_url nil
  json.date_received application.date_received
  json.on_notice_from application.on_notice_from
  json.on_notice_to application.on_notice_to
  json.authority do
    json.full_name application.authority.full_name
  end
end
