class EmailConfirmable::Notifier < ActionMailer::Base
  def confirm(object)
    class_name = object.class.name.underscore
    # This seems a bit long-winded. Is there a better way?
    instance_variable_set(("@" + class_name).to_sym, object)

    mail(:to => object.email, :subject => "Please confirm your #{object.class.model_name.human.downcase}",
      :from => EmailConfirmable.from, :template_name => class_name)
  end
end
