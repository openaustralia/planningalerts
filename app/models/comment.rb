# typed: true
# frozen_string_literal: true

require "rest-client"

class Comment < ApplicationRecord
  belongs_to :application
  belongs_to :councillor, optional: true
  has_many :reports, dependent: :restrict_with_exception
  has_many :replies, dependent: :restrict_with_exception
  validates :name, presence: true
  validates :text, presence: true
  validates :address, presence: true, unless: :to_councillor?

  include EmailConfirmable
  scope(:visible, -> { where(confirmed: true, hidden: false) })
  scope(:in_past_week, -> { where("created_at > ?", 7.days.ago) })
  scope(:to_councillor, -> { joins(:councillor) })

  counter_culture :application,
                  column_name: proc { |comment| comment.visible? ? "visible_comments_count" : nil },
                  column_names: {
                    "comments.confirmed = true and comments.hidden = false" => "visible_comments_count"
                  }

  def visible?
    confirmed && !hidden
  end

  def confirm!
    return if confirmed

    update!(confirmed: true, confirmed_at: Time.current)
    send_comment!
  end

  def send_comment!
    if to_councillor? && ENV["WRITEIT_BASE_URL"]
      CommentMailer.send_comment_via_writeit!(self).deliver_later
    elsif to_councillor?
      CommentMailer.notify_councillor(self).deliver_later
    else
      CommentMailer.notify_authority(self).deliver_later
    end
  end

  def to_councillor?
    councillor.present?
  end

  def awaiting_councillor_reply?
    to_councillor? && replies.empty?
  end

  def recipient_display_name
    c = councillor
    c ? c.prefixed_name : application.authority.full_name
  end

  def writeitinstance
    writeitinstance = WriteItInstance.new
    writeitinstance.base_url = ENV["WRITEIT_BASE_URL"]
    writeitinstance.url = ENV["WRITEIT_URL"]
    writeitinstance.username = ENV["WRITEIT_USERNAME"]
    writeitinstance.api_key = ENV["WRITEIT_API_KEY"]

    writeitinstance
  end

  def create_replies_from_writeit!
    return if writeit_message_id.blank?

    # TODO: This should be done in the writeit-rails gem
    api_response = RestClient.get(
      T.must(ENV["WRITEIT_BASE_URL"]) + "/api/v1/message/" + writeit_message_id.to_s,
      params: { format: "json",
                username: writeitinstance.username,
                api_key: writeitinstance.api_key }
    )
    message = JSON.parse(api_response.body, symbolize_names: true)
    answers = message[:answers]

    answers.collect do |answer|
      next if replies.find_by(writeit_id: answer[:id])

      replies.create!(councillor: councillor,
                      text: answer[:content],
                      received_at: answer[:created],
                      writeit_id: answer[:id])
    end.compact
  end
end
