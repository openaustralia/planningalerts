# typed: strict
# frozen_string_literal: true

class NotifySlackCommentDeliveryService < ApplicationService
  extend T::Sig

  sig do
    params(
      comment: Comment,
      to: String,
      status: String,
      extended_status: String,
      email_id: Integer
    ).void
  end
  def self.call(comment:, to:, status:, extended_status:, email_id:)
    new(
      comment: comment,
      to: to,
      status: status,
      extended_status: extended_status,
      email_id: email_id
    ).call
  end

  sig do
    params(
      comment: Comment,
      to: String,
      status: String,
      extended_status: String,
      email_id: Integer
    ).void
  end
  def initialize(comment:, to:, status:, extended_status:, email_id:)
    @comment = comment
    @to = to
    @status = status
    @extended_status = extended_status
    @email_id = email_id
  end

  sig { void }
  def call
    notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"]
    if status == "delivered"
      notifier.ping "A [comment](#{comment_url}) was succesfully [delivered](#{email_url}) to #{comment.application.authority.full_name} #{to}"
    elsif status == "soft_bounce"
      notifier.ping "A [comment](#{comment_url}) soft bounced when [delivered](#{email_url}) to #{comment.application.authority.full_name} #{to}. Their email server said \"#{extended_status}\""
    elsif status == "hard_bounce"
      notifier.ping "A [comment](#{comment_url}) hard bounced when [delivered](#{email_url}) to #{comment.application.authority.full_name} #{to}. Their email server said \"#{extended_status}\""
    else
      raise "Unexpected status"
    end
  end

  sig { returns(String) }
  def email_url
    "https://cuttlefish.oaf.org.au/emails/#{email_id}"
  end

  sig { returns(String) }
  def comment_url
    Rails.application.routes.url_helpers.nimda_comment_url(comment, host: ENV["HOST"])
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
end
