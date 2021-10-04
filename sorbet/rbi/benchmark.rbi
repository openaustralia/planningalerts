# typed: true

# For some reason we can't get the rails extension to Benchmark be seen by
# tapioca. Would have expected to just add 'require "active_support/core_ext/benchmark"'
# to sorbet/tapioca/require.rb and run 'bundle exec tapioca generate' but that
# didn't add anything.

module Benchmark
  def self.ms; end
end
