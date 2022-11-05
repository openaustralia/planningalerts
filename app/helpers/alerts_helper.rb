# typed: strict
# frozen_string_literal: true

module AlertsHelper
  extend T::Sig

  include ApplicationHelper

  sig { params(size: Integer).returns(T.nilable(String)) }
  def size_option_word(size)
    case size
    when 200
      "street"
    when 800
      "neighbourhood"
    when 2000
      "suburb"
    end
  end

  sig { params(size: Integer).returns(String) }
  def size_option_sentence(size)
    w = size_option_word(size)
    if w
      "My #{w} (within #{meters_in_words(size.to_f)})"
    else
      "Within #{meters_in_words(size.to_f)}"
    end
  end
end
