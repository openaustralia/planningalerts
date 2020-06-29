# typed: false
# frozen_string_literal: true

require "standalone_sweeper"

class StatSweeper < StandaloneSweeper
  observe Stat

  def after_save(_stat)
    expire_page(controller: "static", action: %w[about faq get_involved])
  end
end
