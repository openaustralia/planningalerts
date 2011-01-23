class Array

  ##
  # Taken from http://snippets.dzone.com/posts/show/302
  #
  # >> %W{ a b c }.to_hash_with( %W{ 1 2 3 } )
  # => {"a"=>"1", "b"=>"2", "c"=>"3"}
  #
  def to_hash_with(other)
    Hash[ *(0...self.size()).inject([]) { |arr, ix| arr.push(self[ix], other[ix]) } ]
  end

end
