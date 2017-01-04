require "rest-client"

class Comment < ActiveRecord::Base
  belongs_to :application
  belongs_to :councillor
  has_many :reports
  has_many :replies
  validates_presence_of :name, :text
  validates_presence_of :address, unless: :to_councillor?

  include EmailConfirmable
  scope :visible, -> { where(confirmed: true, hidden: false) }
  scope :in_past_week, -> { where("created_at > ?", 7.days.ago) }
  scope :to_councillor, -> { joins(:councillor) }

  scope :visible_with_unique_emails_for_date, ->(date) {
    visible.where("date(confirmed_at) = ?", date).group(:email)
  }

  scope :by_first_time_commenters_for_date, ->(date) {
    visible_with_unique_emails_for_date(date)
    .select {|c| where("email = ? AND confirmed_at < ?", c.email, c.confirmed_at.to_date).empty? }
  }

  scope :by_returning_commenters_for_date, ->(date) {
    visible_with_unique_emails_for_date(date)
    .select {|c| where("email = ? AND confirmed_at < ?", c.email, c.confirmed_at.to_date).any? }
  }

  def confirm!
    unless confirmed
      update!(confirmed: true, confirmed_at: Time.current)
      send_comment!
    end
  end

  def send_comment!
    if to_councillor? && ENV["WRITEIT_BASE_URL"]
      CommentNotifier.send_comment_via_writeit!(self).deliver_later
    elsif to_councillor?
      CommentNotifier.notify_councillor("default", self).deliver_later
    else
      CommentNotifier.notify_authority("default", self).deliver_later
    end
  end

  def to_councillor?
    councillor.present?
  end

  def awaiting_councillor_reply?
    to_councillor? && replies.empty?
  end

  def recipient_display_name
    to_councillor? ? councillor.prefixed_name : application.authority.full_name
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
    if writeit_message_id.present?
      # TODO: This should be done in the writeit-rails gem
      api_response = RestClient.get(
        ENV["WRITEIT_BASE_URL"] + "/api/v1/message/" + writeit_message_id.to_s,
        params: { format: "json",
                  username: writeitinstance.username,
                  api_key: writeitinstance.api_key }
      )
      message = JSON.parse(api_response.body, symbolize_names: true)
      answers = message[:answers]

      answers.collect do |answer|
        unless replies.find_by(writeit_id: answer[:id])
          replies.create!(councillor: councillor,
                          text: answer[:content],
                          received_at: answer[:created],
                          writeit_id: answer[:id])
        end
      end.compact
    end
  end
end
