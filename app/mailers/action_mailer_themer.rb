# frozen_string_literal: true

module ActionMailerThemer
  private

  def themed_mail(params)
    @themer = DefaultTheme.new
    @host = @themer.host
    @protocol = @themer.protocol

    # Rails 4.0 supports a delivery_method_options as an option in the main method
    # In Rails 3.2 we have to do things more manually by setting the delivery settings
    # on the returned mail object
    mail(params.merge(template_path: mailer_name))
  end

  def email_from
    DefaultTheme.new.email_from
  end

  def host
    DefaultTheme.new.host
  end

  def protocol
    DefaultTheme.new.protocol
  end
end
