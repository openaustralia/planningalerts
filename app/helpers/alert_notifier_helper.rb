# frozen_string_literal: true

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

  def application_url_with_tracking(id: nil)
    base_params = host_and_protocol_for_theme("default").merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: id,
        utm_campaign: "view-application"
      )
    )
  end

  def comment_url_with_tracking(comment: nil)
    base_params = host_and_protocol_for_theme("default").merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: comment.application.id,
        anchor: "comment#{comment.id}",
        utm_campaign: "view-comment"
      )
    )
  end

  def reply_url_with_tracking(reply: nil)
    base_params = host_and_protocol_for_theme("default").merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: reply.comment.application.id,
        anchor: "reply#{reply.id}",
        utm_campaign: "view-reply"
      )
    )
  end

  def new_comment_url_with_tracking(id: nil)
    base_params = host_and_protocol_for_theme("default").merge(base_tracking_params)

    application_url(
      base_params.merge(
        id: id,
        anchor: "add-comment",
        utm_campaign: "add-comment"
      )
    )
  end

  def new_donation_url_with_tracking
    base_params = host_and_protocol_for_theme("default").merge(base_tracking_params)

    new_donation_url(
      base_params.merge(
        utm_campaign:  "donate-from-alert",
        email: @alert.email
      )
    )
  end

  def subject(alert, applications, comments, replies)
    applications_text = pluralize(applications.size, "new planning application") if applications.any?
    comments_text = pluralize(comments.size, "new comment") if comments.any?
    replies_text = pluralize(replies.size, "new reply") if replies.any?

    items = [comments_text, replies_text, applications_text].compact.to_sentence(last_word_connector: " and ")
    items += " on planning applications" if applications.empty?

    "#{items} near #{alert.address}"
  end
end
