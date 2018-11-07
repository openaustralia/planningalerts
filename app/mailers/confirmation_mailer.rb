class ConfirmationMailer < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def confirm(theme, object)
    class_name = object.class.name.underscore
    # This seems a bit long-winded. Is there a better way?
    instance_variable_set(("@" + class_name).to_sym, object)

    themed_mail(
      theme: theme, to: object.email,
      subject: "Please confirm your #{object.class.model_name.human.downcase}",
      from: email_from(theme), template_name: class_name
    )
  end
end
