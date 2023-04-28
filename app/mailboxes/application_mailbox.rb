# typed: strict
# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  routing(/^do-not-reply@/ => :do_not_replies)
end
