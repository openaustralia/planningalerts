# typed: strict
# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  routing(/^no-reply@/ => :do_not_replies)
end
