# typed: strict
# frozen_string_literal: true

class DoNotRepliesMailbox < ApplicationMailbox
  extend T::Sig

  sig { void }
  def process; end
end
