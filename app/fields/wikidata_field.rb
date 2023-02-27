# typed: strict
# frozen_string_literal: true

require "administrate/field/base"

class WikidataField < Administrate::Field::Base
  extend T::Sig

  sig { returns(String) }
  def to_s
    data
  end
end
