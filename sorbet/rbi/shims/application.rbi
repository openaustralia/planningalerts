# typed: true

# Doing this to add the searchkick bit in. Couldn't find another way to do this. Ugh.

class Application < ApplicationRecord
  def self.search(term, **options, &block); end
  def reindex; end
end
