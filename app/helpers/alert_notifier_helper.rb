module AlertNotifierHelper
  include ActionMailerThemer

  def host_and_protocol_for_theme(theme)
    { host: host(theme), protocol: protocol(theme) }
  end

  def base_tracking_params
    { utm_source: "alerts", utm_medium: "email" }
  end

  def application_url_with_tracking(theme: nil, id: nil)
    base_params = host_and_protocol_for_theme(theme)
                       .merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: id,
        utm_campaign: 'view-application'
      )
    )
  end

  def comment_url_with_tracking(theme: nil, comment: nil)
    base_params = host_and_protocol_for_theme(theme)
                       .merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: comment.application.id,
        anchor: "comment#{comment.id}",
        utm_campaign: "view-comment"
      )
    )
  end

  def new_comment_url_with_tracking(theme: nil, id: nil)
    base_params = host_and_protocol_for_theme(theme)
                       .merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: id,
        anchor: 'add-comment',
        utm_campaign: 'add-comment'
      )
    )
  end

  def new_subscription_url_with_tracking(alert: nil, utm_content: '')
    if alert.expired_subscription?
      utm_campaign = "subscribe-from-expired"
    elsif alert.trial_subscription?
      utm_campaign = "subscribe-from-trial"
    end

    params = base_tracking_params.merge(
      utm_campaign: utm_campaign,
      email: @alert.email
    )

    params.merge!(utm_content: utm_content) unless utm_content.blank?

    new_subscription_url(params)
  end
end
