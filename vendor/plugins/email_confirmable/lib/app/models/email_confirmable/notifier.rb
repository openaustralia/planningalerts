class EmailConfirmable::Notifier < ActionMailer::Base
  def confirm(object)
    class_name = object.class.name.underscore
    @recipients = object.email
    @from = EmailConfirmable.from
    @subject = "Please confirm your #{object.class.human_name.downcase}"
    # This seems a bit long-winded. Is there a better way?
    instance_variable_set(("@" + class_name).to_sym, object)
    template class_name
  end
end
