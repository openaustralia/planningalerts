# typed: false
# frozen_string_literal: true

require "administrate/field/base"

class YesNoBooleanField < Administrate::Field::Base
  extend T::Sig

  sig { returns(String) }
  def to_s
    if data.nil?
      "-"
    elsif data
      "yes"
    else
      "no"
    end
  end
end
