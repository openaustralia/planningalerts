# frozen_string_literal: true

# Fails the spec run if anything printed a deprecation warning, listing each
# one, so an upgrade can't leave warnings scrolled away in the output.
# Catches Rails' deprecators (which still print to stderr as before) and
# anything sent through Ruby's Warning.warn, which is how gems usually warn.
module DeprecationCheck
  @found = Set.new
  # Feature specs with JavaScript serve requests from another thread
  @lock = Mutex.new

  class << self
    attr_reader :found

    def record(message)
      @lock.synchronize { @found << message.strip }
    end
  end

  # Prepended to Warning, so it sees every Kernel#warn and Ruby warning
  module WarningHook
    def warn(message, category: nil, **kwargs)
      DeprecationCheck.record(message) if category == :deprecated || message.match?(/deprecat/i)
      super
    end
  end
end

Warning.singleton_class.prepend(DeprecationCheck::WarningHook)

Rails.application.deprecators.each do |deprecator|
  deprecator.behavior = deprecator.behavior + [->(message, *) { DeprecationCheck.record(message) }]
end

RSpec.configure do |config|
  config.after(:suite) do
    next if DeprecationCheck.found.empty?

    raise "Deprecation warnings (fix them before upgrading):\n  #{DeprecationCheck.found.sort.join("\n  ")}"
  end
end
