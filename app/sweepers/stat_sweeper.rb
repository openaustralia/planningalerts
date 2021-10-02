# typed: false
# frozen_string_literal: true

require "standalone_sweeper"

class StatSweeper < StandaloneSweeper
  extend T::Sig

  observe Stat

  sig { params(_stat: Stat).void }
  def after_save(_stat)
    expire_page(controller: "static", action: %w[about faq get_involved])
  end
end
