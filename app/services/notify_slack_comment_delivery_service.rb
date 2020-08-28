# typed: strict
# frozen_string_literal: true

class NotifySlackCommentDeliveryService < ApplicationService
  extend T::Sig

  sig { params(comment: Comment, to: String, status: String, extended_status: String).void }
  def self.call(comment:, to:, status:, extended_status:)
    new(comment: comment, to: to, status: status, extended_status: extended_status).call
  end

  sig { params(comment: Comment, to: String, status: String, extended_status: String).void }
  def initialize(comment:, to:, status:, extended_status:)
    @comment = comment
    @to = to
    @status = status
    @extended_status = extended_status
  end

  sig { void }
  def call
    notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"]
    if status == "delivered"
      notifier.ping "A comment was succesfully delivered to #{comment.application.authority.full_name} with email #{to}"
    elsif status == "soft_bounce"
      notifier.ping "A comment soft bounced when delivered to #{comment.application.authority.full_name} with email #{to}. Their email server said \"#{extended_status}\""
    elsif status == "hard_bounce"
      notifier.ping "A comment hard bounced when delivered to #{comment.application.authority.full_name} with email #{to}. Their email server said \"#{extended_status}\""
    else
      raise "Unexpected status"
    end
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
end
