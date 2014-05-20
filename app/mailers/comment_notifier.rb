class CommentNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def notify(theme, comment)
    @comment = comment

    if theme == "default"
      sender = "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
    elsif theme == "nsw"
      sender = "NSW PlanningAlerts <contact@planningalerts.nsw.gov.au>"
    else
      raise "Unknown theme #{theme}"
    end

    themed_mail(:theme => theme, :from => "#{comment.name} <#{comment.email}>",
      :sender => sender,
      # Setting reply-to to ensure that we don't get the replies for email clients that are not
      # respecting the from, sender headers that we've set.
      :reply_to => "#{comment.name} <#{comment.email}>",
      :to => comment.application.authority.email, :subject => "Comment on application #{comment.application.council_reference}")
  end
end
