class TypusMailer < ActionMailer::Base

  self.template_root = "#{File.dirname(__FILE__)}/../views"

  def reset_password_link(user, url)
    subject     "[#{Typus::Configuration.options[:app_name]}] #{_("Reset password")}"
    body        :user => user, :url => url
    recipients  user.email
    from        Typus::Configuration.options[:email]
  end

end
