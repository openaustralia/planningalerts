# frozen_string_literal: true

module ActionMailerThemer
  private

  def themed_mail(params)
    @host = host
    @protocol = protocol

    # Rails 4.0 supports a delivery_method_options as an option in the main method
    # In Rails 3.2 we have to do things more manually by setting the delivery settings
    # on the returned mail object
    mail(params.merge(template_path: mailer_name))
  end

  def email_from
    "#{ENV['EMAIL_FROM_NAME']} <#{ENV['EMAIL_FROM_ADDRESS']}>"
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end

  def protocol
    "https"
  end
end
