# typed: strict
# frozen_string_literal: true

class AtdisController < ApplicationController
  extend T::Sig

  # TODO: Move redirect to routes
  sig { void }
  def test
    redirect_to get_involved_path
  end

  # TODO: Move redirect to routes
  sig { void }
  def specification
    redirect_to "https://github.com/openaustralia/atdis/raw/master/docs/ATDIS-1.0.2%20Application%20Tracking%20Data%20Interchange%20Specification%20(v1.0.2).pdf"
  end
end
