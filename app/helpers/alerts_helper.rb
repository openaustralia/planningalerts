# typed: strict
# frozen_string_literal: true

module AlertsHelper
  extend T::Sig

  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  sig { params(size: Integer).returns(String) }
  def size_option_sentence(size)
    w = Alert::RADIUS_DESCRIPTIONS[size]
    if w
      "My #{w} (within #{meters_in_words(size.to_f)})"
    else
      "Within #{meters_in_words(size.to_f)}"
    end
  end

  sig { params(date: T.nilable(Time)).returns(String) }
  def last_sent_in_words(date)
    if date
      "Last sent #{time_ago_in_words(date)} ago"
    else
      "Not yet sent"
    end
  end
end
