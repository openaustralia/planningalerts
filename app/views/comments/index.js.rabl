# frozen_string_literal: true

collection @comments
attributes :id, :text, :name, :updated_at

child :application do
  attributes :id,
             :council_reference,
             :address,
             :description,
             :info_url,
             :comment_url,
             :lat,
             :lng,
             :date_scraped,
             :date_received,
             :on_notice_from,
             :on_notice_to,
             :no_alerted
end
