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

    @georss_url = url_for(:host => Configuration::HOST, :controller => "api", :call => "address", :address => @user.address, :area_size => @user.area_size_meters)
    @unsubscribe_url = url_for(:host => Configuration::HOST, :controller => "signup", :action => "unsubscribe", :cid => @user.confirm_id)
  end
end
