# typed: strict
# frozen_string_literal: true

# A Flipper actor for someone who is not signed in.
#
# Most feature flags here are read as Flipper.enabled?(:flag, current_user),
# which cannot work on a form used by people who are logged out: the actor is
# nil, so only the boolean and group gates ever apply. A Visitor gives those
# people a stable flipper_id, so a percentage gate can be used to roll a change
# out to a fraction of them.
#
# Stability is the whole point. A form is rendered on one request and checked on
# another, and both requests must get the same answer from Flipper, or someone
# is shown a form without a widget and then told their answer was missing.
class Visitor
  extend T::Sig
  include Flipper::Identifier

  sig { returns(String) }
  attr_reader :id

  sig { params(id: String).void }
  def initialize(id)
    @id = id
  end

  sig { params(other: T.untyped).returns(T::Boolean) }
  def ==(other)
    return false unless other.is_a?(Visitor)

    other.id == id
  end
end
