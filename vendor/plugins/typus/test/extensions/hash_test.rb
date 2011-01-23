require 'test/helper'

class HashTest < ActiveSupport::TestCase

  def test_should_verify_compact
    hash = { 'a' => '', 'b'=> nil, 'c' => 'hello', 'd' => 1 }
    hash_compacted = { 'c' => 'hello', 'd' => 1 }
    assert_equal hash_compacted, hash.compact
  end

end