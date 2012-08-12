
class AlertNotifier < ActionMailer::Base
  default :from => "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
  helper :application
  # So that we can use "pluralize"
  include ActionView::Helpers::TextHelper

  def alert(alert, applications, comments = [])
    @alert = alert
    @applications = applications

    @georss_url = applications_url(:format => "rss", :address => @alert.address, :radius => @alert.radius_meters)
    
    # Update statistics. Is this a good place to do them or would it make more sense to do it after the mailing has
    # happened and we can check whether is was sucessful?
    # TODO: Once we put caching in place this will mean that the stats will be updated frequently during the sending
    # out of all the email alerts. This means that the cache will be continuously dirtied during the email alerts
    # and the performance of all the page loads will suffer (as they contain statistics)
    Stat.emails_sent += 1
    Stat.applications_sent += applications.count
    # TODO: Like the comment above, is this really a good place to update the model?
    alert.last_sent = Time.now
    alert.save!
    
    if applications.empty?
      subject = "1 new comment on planning applications near #{alert.address}"
    else
      subject = pluralize(applications.count, "new planning application") + " near #{alert.address}"
    end

    mail(:to => alert.email, :subject => subject, "return-path" => ::Configuration::BOUNCE_EMAIL_ADDRESS)
  end
end
