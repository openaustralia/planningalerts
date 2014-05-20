class EmailConfirmable::Notifier < ActionMailer::Base
  include ActionMailerThemer

  def confirm(theme, object)
    class_name = object.class.name.underscore
    # This seems a bit long-winded. Is there a better way?
    instance_variable_set(("@" + class_name).to_sym, object)

    if theme == "default"
      from = "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
    elsif theme == "nsw"
      from = "NSW PlanningAlerts <contact@planningalerts.nsw.gov.au>"
    else
      raise "unknown theme"
    end

    themed_mail(:theme => theme, :to => object.email,
      :subject => "Please confirm your #{object.class.model_name.human.downcase}",
      :from => from, :template_name => class_name)
  end
end
