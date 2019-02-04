# frozen_string_literal: true

class CommentMailer < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def notify_authority(comment)
    @comment = comment

    mail(
      from: "#{comment.name} <#{comment.email}>",
      sender: email_from,
      # Setting reply-to to ensure that we don't get the replies for email clients that are not
      # respecting the from, sender headers that we've set.
      reply_to: "#{comment.name} <#{comment.email}>",
      to: comment.application.authority.email, subject: "Comment on application #{comment.application.council_reference}"
    )
  end

  def notify_councillor(comment)
    @comment = comment
    from_address = ENV["EMAIL_COUNCILLOR_REPLIES_TO"]

    mail(
      from: "#{comment.name} <#{from_address}>",
      sender: email_from,
      reply_to: "#{comment.name} <#{from_address}>",
      to: comment.councillor.email, subject: "Planning application at #{comment.application.address}"
    )
  end

  # FIXME: This probably shouldn't be in the mailer
  def send_comment_via_writeit!(comment)
    @comment = comment

    message = Message.new
    message.subject = "Planning application at #{comment.application.address}"
    message.content = render_to_string("notify_councillor.text.erb")
    message.author_name = comment.name
    message.author_email = ENV["EMAIL_COUNCILLOR_REPLIES_TO"]
    message.writeitinstance = comment.writeitinstance
    message.recipients = [comment.councillor.writeit_id]
    message.push_to_api
    comment.update!(writeit_message_id: message.remote_id)
  end
end
