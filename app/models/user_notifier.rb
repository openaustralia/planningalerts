class UserNotifier < ActionMailer::Base
  def confirm(user)
    @recipients = user.email
    @from = "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
    @subject = "Please confirm your planning alert"
    @user = user
  end
  
  def alert(user, applications)
    @recipients = user.email
    @from = "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
    @subject = "Planning applications near #{user.address}"
    @user = user
    @applications = applications

    @georss_url = url_for(:host => Configuration::HOST, :controller => "api", :call => "address", :address => @user.address, :area_size => @user.area_size_meters)
    @unsubscribe_url = url_for(:host => Configuration::HOST, :controller => "signup", :action => "unsubscribe", :cid => @user.confirm_id)
    
    # Update statistics. Is this a good place to do them or would it make more sense to do it after the mailing has
    # happened and we can check whether is was sucessful?
    # TODO: Once we put caching in place this will mean that the stats will be updated frequently during the sending
    # out of all the email alerts. This means that the cache will be continuously dirtied during the email alerts
    # and the performance of all the page loads will suffer (as they contain statistics)
    Stat.emails_sent += 1
    Stat.applications_sent += applications.count
    # TODO: Like the comment above, is this really a good place to update the model?
    user.last_sent = Time.now
    user.save!
  end
end
