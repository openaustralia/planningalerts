module AlertNotifierHelper
  def base_tracking_params
    return { utm_source: "alerts", utm_medium: "email" }
  end

  def application_url_with_tracking(protocol: nil, host: nil, id: nil)
    return application_url(
          base_tracking_params.merge(
            protocol: protocol,
            host: host,
            id: id,
            utm_campaign: 'view-application'
          )
        )
  end

  def new_comment_url_with_tracking(protocol: nil, host: nil, id: nil)
    return application_url(
          base_tracking_params.merge(
            protocol: protocol,
            host: host,
            id: id,
            utm_campaign: 'add-comment',
            anchor: 'add-comment'
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

    return new_subscription_url(params)
  end
end
