# typed: strict
# frozen_string_literal: true

# The ALTCHA proof-of-work check that appears on our public forms.
#
# ALTCHA is self-hosted: the widget asks our own server for a challenge and
# nothing is sent to a third party. See doc/altcha.md.
#
# Renders nothing unless this person is meant to see a check, so a form can ask
# for it unconditionally.
class AltchaWidgetComponent < ViewComponent::Base
  extend T::Sig

  # The hidden input the widget fills in. Controllers read params[:altcha].
  FIELD_NAME = T.let("altcha", String)

  sig { returns(T::Boolean) }
  def render?
    helpers.altcha_required?
  end
end
