class UserNotifier < ActionMailer::Base
  def confirm(user)
    @recipients = user.email
    # TODO: This email address should be picked up from a configuration file
    @from = "contact@planningalerts.org.au"
    @subject = "Please confirm your planning alert"
    @user = user
  end
end
