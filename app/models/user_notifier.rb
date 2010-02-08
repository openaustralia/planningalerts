class UserNotifier < ActionMailer::Base
  def confirm(user)
    @recipients = user.email
    @from = Configuration::EMAIL_FROM_ADDRESS
    @subject = "Please confirm your planning alert"
    @user = user
  end
  
  def alert(user, applications)
    @recipients = user.email
    @from = Configuration::EMAIL_FROM_ADDRESS
    @subject = "Planning applications near #{user.address}"
    @user = user
    @applications = applications

    @georss_url = url_for(:host => "example.org", :controller => "api", :call => "address", :address => @user.address, :area_size => @user.area_size_meters)
    @base_url = "http://example.org"
  end
end
