# typed: strict
# frozen_string_literal: true

require "administrate/field/base"

class UrlField < Administrate::Field::Base
  def to_s
    data
  end
end
