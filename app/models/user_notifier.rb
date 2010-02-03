class UserNotifier < ActionMailer::Base
  def confirm(user)
    @recipients = user.email
    @from = Configuration::EMAIL_FROM_ADDRESS
    @subject = "Please confirm your planning alert"
    @user = user
  end
end
