module ActionMailerThemer

  private

  def themed_mail(params)
    theme = params.delete(:theme)
    @themer = ThemeChooser.create(theme)

    if @themer.view_path
      self.prepend_view_path @themer.view_path
      template_path = [File.join(@themer.view_path, mailer_name), mailer_name]
    else
      template_path = mailer_name
    end

    @host = @themer.host
    @protocol = @themer.protocol
    # Only override mail delivery options in production
    if Rails.env.production? && @themer.delivery_options
      delivery_options = @themer.delivery_options
    else
      delivery_options = {}
    end

    # Rails 4.0 supports a delivery_method_options as an option in the main method
    # In Rails 3.2 we have to do things more manually by setting the delivery settings
    # on the returned mail object
    m = mail(params.merge(template_path: template_path))
    m.delivery_method.settings.merge!(delivery_options)
    m
  end

  def email_from(theme)
    ThemeChooser.create(theme).email_from
  end

  def host(theme)
    ThemeChooser.create(theme).host
  end

  def protocol(theme)
    ThemeChooser.create(theme).protocol
  end
end
