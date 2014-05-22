module ActionMailerThemer

  private

  def themed_mail(params)
    theme = params.delete(:theme)

    # TODO Extract this into the theme
    if theme == "default"
      template_path = mailer_name
    elsif theme == "nsw"
      template_path = ["../../lib/themes/#{theme}/views/#{mailer_name}", mailer_name]
      self.prepend_view_path "lib/themes/#{theme}/views"
    else
      raise "Unknown theme #{theme}"
    end

    themer = ThemeChooser.create(theme)
    @host = themer.host
    # Only override mail delivery options in production
    if Rails.env.production? && theme == "nsw"
      delivery_options = {user_name: themer.cuttlefish_user_name , password: themer.cuttlefish_password }
    else
      delivery_options = {}
    end

    mail(params.merge(template_path: template_path, delivery_method_options: delivery_options))
  end

  def email_from(theme)
    ThemeChooser.create(theme).email_from
  end
end
