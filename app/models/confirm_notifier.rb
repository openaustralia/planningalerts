class ConfirmNotifier < ActionMailer::Base
  helper :application

  def confirm(object)
    class_name = object.class.name.underscore
    @recipients = object.email
    @from = "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
    @subject = "Please confirm your #{object.class.human_name.downcase}"
    # This seems a bit long-winded. Is there a better way?
    instance_variable_set(("@" + class_name).to_sym, object)
    template class_name
  end
end
