# typed: strict
# frozen_string_literal: true

module AlertsHelper
  extend T::Sig

  include ApplicationHelper

  sig { params(size: Integer).returns(String) }
  def size_option_sentence(size)
    w = Alert::RADIUS_DESCRIPTIONS[size]
    if w
      "My #{w} (within #{meters_in_words(size.to_f)})"
    else
      "Within #{meters_in_words(size.to_f)}"
    end
  end
end
