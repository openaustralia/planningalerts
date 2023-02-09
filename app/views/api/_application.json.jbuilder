# typed: strict
# frozen_string_literal: true

json.application do
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
  json.lat application.lat
  json.lng application.lng
  json.authority do
    json.full_name application.authority.full_name
  end
end
