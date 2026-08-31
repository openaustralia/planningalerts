# typed: strict
# frozen_string_literal: true

class NotifySlackCommentDeliveryService
  extend T::Sig

  sig do
    params(
      comment: Comment,
      to: String,
      status: String,
      extended_status: String,
      email_id: Integer,
      email_url: String
    ).void
  end
  def self.call(comment:, to:, status:, extended_status:, email_id:, email_url: "https://cuttlefish.oaf.org.au/emails/#{email_id}")
    new(
      comment:,
      to:,
      status:,
      extended_status:,
      email_id:,
      email_url:
    ).call
  end

  sig do
    params(
      comment: Comment,
      to: String,
      status: String,
      extended_status: String,
      email_id: Integer,
      email_url: String
    ).void
  end
  def initialize(comment:, to:, status:, extended_status:, email_id:, email_url: "https://cuttlefish.oaf.org.au/emails/#{email_id}")
    @comment = comment
    @to = to
    @status = status
    @extended_status = extended_status
    @email_id = email_id
    @email_url = email_url
  end

  sig { void }
  def call
    notifier = Slack::Notifier.new(Rails.application.credentials[:slack_webhook_url])
    case status
    when "delivered"
      notifier.ping "A [comment](#{comment_url}) was successfully [delivered](#{email_url}) to #{comment.application&.authority&.full_name} #{to}"
    when "soft_bounce"
      notifier.ping "A [comment](#{comment_url}) soft bounced when [delivered](#{email_url}) to #{comment.application&.authority&.full_name} #{to}. Their email server said \"#{extended_status}\""
    when "hard_bounce"
      notifier.ping "A [comment](#{comment_url}) hard bounced when [delivered](#{email_url}) to #{comment.application&.authority&.full_name} #{to}. Their email server said \"#{extended_status}\""
    when "held"
      notifier.ping "A [comment](#{comment_url}) was held by the mail server when [delivering](#{email_url}) to #{comment.application&.authority&.full_name} #{to} - it may be on the suppression list."
    else
      raise "Unexpected status"
    end
  end

  sig { returns(String) }
  def comment_url
    Rails.application.routes.url_helpers.admin_comment_url(comment, host: Rails.configuration.x.host)
  end

  private

  sig { returns(Comment) }
  attr_reader :comment

  sig { returns(String) }
  attr_reader :to

  sig { returns(String) }
  attr_reader :status

  sig { returns(String) }
  attr_reader :extended_status

  sig { returns(Integer) }
  attr_reader :email_id

  sig { returns(String) }
  attr_reader :email_url
end
