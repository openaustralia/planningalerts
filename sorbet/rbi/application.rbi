# typed: true

# Doing this to add the sidekiq bit in. Couldn't find another way to do this. Ugh.

class Application < ApplicationRecord
  def self.search(term, **options, &block); end
end
