# frozen_string_literal: true

class ConfirmationMailer < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def confirm(object)
    class_name = object.class.name.underscore
    # This seems a bit long-winded. Is there a better way?
    instance_variable_set(("@" + class_name).to_sym, object)

    themed_mail(
      theme: "default", to: object.email,
      subject: "Please confirm your #{object.class.model_name.human.downcase}",
      from: email_from("default"), template_name: class_name
    )
  end
end
