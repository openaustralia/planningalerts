require "rest-client"

class Comment < ActiveRecord::Base
  belongs_to :application
  belongs_to :councillor
  has_many :reports
  has_many :replies
  validates_presence_of :name, :text
  validates_presence_of :address, unless: :to_councillor?

  acts_as_email_confirmable
  scope :visible, -> { where(confirmed: true, hidden: false) }
  scope :in_past_week, -> { where("created_at > ?", 7.days.ago) }

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

  # Send the comment to the planning authority
  def after_confirm
    if to_councillor? && ENV["WRITEIT_BASE_URL"]
      send_via_writeit!
    elsif to_councillor?
      CommentNotifier.delay.notify_councillor("default", self)
    else
      CommentNotifier.delay.notify_authority("default", self)
    end
  end

  def to_councillor?
    councillor ? true : false
  end

  def awaiting_councillor_reply?
    to_councillor? && replies.empty?
  end

  def recipient_display_name
    to_councillor? ? councillor.prefixed_name : application.authority.full_name
  end

  def send_via_writeit!
    # TODO: Put this on the background queue
    message = Message.new
    message.subject = "Planning application at #{application.address}"
    # TODO: Add boiler plate
    message.content = text
    message.author_name = name
    message.author_email = ENV["EMAIL_COUNCILLOR_REPLIES_TO"]
    message.writeitinstance = writeitinstance
    message.recipients = [councillor.writeit_id]
    message.push_to_api
    update!(writeit_message_id: message.remote_id)
  end

  def writeitinstance
    writeitinstance = WriteItInstance.new
    writeitinstance.base_url = ENV["WRITEIT_BASE_URL"]
    writeitinstance.url = ENV["WRITEIT_URL"]
    writeitinstance.username = ENV["WRITEIT_USERNAME"]
    writeitinstance.api_key = ENV["WRITEIT_API_KEY"]

    writeitinstance
  end

  def create_reply_from_writeit!
    if replies.present? || writeit_message_id.blank?
      false
    else
      # TODO: This should be done in the writeit-rails gem
      api_response = RestClient.get(ENV["WRITEIT_BASE_URL"] + "/api/v1/message/" + writeit_message_id.to_s,
                                    {params: {format: "json",
                                              username: writeitinstance.username,
                                              api_key: writeitinstance.api_key}})
      message = JSON.parse(api_response.body, symbolize_names: true)

      if answer = message[:answers].first
        replies.create!(councillor: councillor,
                        text: answer[:content],
                        received_at: answer[:created],
                        writeit_id: answer[:id])
      end
    end
  end
end
