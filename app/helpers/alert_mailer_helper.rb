# typed: false
# frozen_string_literal: true

module AlertMailerHelper
  extend T::Sig

  sig { params(text: String).returns(String) }
  def capitalise_initial_character(text)
    first = text[0]
    if first
      first.upcase + T.must(text[1..])
    else
      ""
    end
  end

  sig { returns(T::Hash[Symbol, String]) }
  def base_tracking_params
    { utm_source: "alerts", utm_medium: "email" }
  end

  sig { params(id: T.nilable(Integer)).returns(String) }
  def application_url_with_tracking(id: nil)
    T.unsafe(self).application_url(
      base_tracking_params.merge(
        id: id,
        utm_campaign: "view-application"
      )
    )
  end

  sig { params(comment: Comment).returns(String) }
  def comment_url_with_tracking(comment:)
    T.unsafe(self).application_url(
      base_tracking_params.merge(
        id: comment.application.id,
        anchor: "comment#{comment.id}",
        utm_campaign: "view-comment"
      )
    )
  end

  sig { params(id: T.nilable(Integer)).returns(String) }
  def new_comment_url_with_tracking(id: nil)
    T.unsafe(self).application_url(
      base_tracking_params.merge(
        id: id,
        anchor: "add-comment",
        utm_campaign: "add-comment"
      )
    )
  end

  sig do
    params(
      alert: Alert,
      applications: T::Array[Application],
      comments: T::Array[Comment]
    ).returns(String)
  end
  def subject(alert, applications, comments)
    applications_text = pluralize(applications.size, "new planning application") if applications.any?
    comments_text = pluralize(comments.size, "new comment") if comments.any?

    items = [comments_text, applications_text].compact.to_sentence(last_word_connector: " and ")
    items += " on planning applications" if applications.empty?

    "#{items} near #{alert.address}"
  end
end
