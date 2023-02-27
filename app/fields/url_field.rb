# typed: strict
# frozen_string_literal: true

require "administrate/field/base"

class UrlField < Administrate::Field::Base
  extend T::Sig

  sig { returns(T.nilable(String)) }
  def to_s
    data
  end
end
