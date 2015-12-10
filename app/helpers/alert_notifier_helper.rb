module AlertNotifierHelper
  include ActionMailerThemer

  def capitalise_initial_character(text)
    text[0].upcase + text[1..-1]
  end

  def host_and_protocol_for_theme(theme)
    { host: host(theme), protocol: protocol(theme) }
  end

  def base_tracking_params
    { utm_source: "alerts", utm_medium: "email" }
  end

  def application_url_with_tracking(theme: nil, id: nil)
    base_params = host_and_protocol_for_theme(theme).merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: id,
        utm_campaign: 'view-application'
      )
    )
  end

  def comment_url_with_tracking(theme: nil, comment: nil)
    base_params = host_and_protocol_for_theme(theme).merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: comment.application.id,
        anchor: "comment#{comment.id}",
        utm_campaign: "view-comment"
      )
    )
  end

  def reply_url_with_tracking(theme: nil, reply: nil)
    base_params = host_and_protocol_for_theme(theme).merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: reply.comment.application.id,
        anchor: "reply#{reply.id}",
        utm_campaign: "view-reply"
      )
    )
  end

  def new_comment_url_with_tracking(theme: nil, id: nil)
    base_params = host_and_protocol_for_theme(theme).merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: id,
        anchor: 'add-comment',
        utm_campaign: 'add-comment'
      )
    )
  end

  def new_subscription_url_with_tracking(alert: nil, utm_content: nil)
    if alert.expired_subscription?
      utm_campaign = "subscribe-from-expired"
    elsif alert.trial_subscription?
      utm_campaign = "subscribe-from-trial"
    end

    params = base_tracking_params.merge(
      utm_campaign: utm_campaign,
      email: @alert.email
    )

    params.merge!(utm_content: utm_content) unless utm_content.nil?

    new_subscription_url(params)
  end

  def subject(alert, applications, comments, replies = [])
    items = if applications.any? && comments.empty? && replies.empty?
              pluralize(applications.size, "new planning application")
            elsif applications.empty? && comments.any? && replies.empty?
              pluralize(comments.size, "new comment") + " on planning applications"
            elsif applications.empty? && comments.empty? && replies.any?
              pluralize(replies.size, "new reply") + " on planning applications"
            elsif applications.any? && comments.any? && replies.empty?
              pluralize(comments.size, "new comment") + " and " + pluralize(applications.size, "new planning application")
            elsif applications.any? && comments.empty? && replies.any?
              pluralize(replies.size, "new reply") + " and " + pluralize(applications.size, "new planning application")
            elsif applications.any? && comments.any? && replies.any?
              pluralize(comments.size, "new comment") +", " + pluralize(replies.size, "new reply") + " and " + pluralize(applications.size, "new planning application")
            end

    if alert.expired_subscription?
      "You’re missing out on #{items} near #{alert.address}"
    else
      "#{items} near #{alert.address}"
    end
  end
end
