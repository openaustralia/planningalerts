# typed: strict
# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  routing(/^no-reply@/ => :no_replies)
end
