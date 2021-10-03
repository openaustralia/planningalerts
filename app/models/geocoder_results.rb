# typed: strict
# frozen_string_literal: true

class GeocoderResults
  extend T::Sig

  sig { returns(T::Array[GeocodedLocation]) }
  attr_reader :all

  sig { returns(T.nilable(String)) }
  attr_reader :error

  sig { params(all: T::Array[GeocodedLocation], error: T.nilable(String)).void }
  def initialize(all, error)
    raise "Can't return results and have an error at the same time" if error && !all.empty?

    @all = all
    @error = error
  end

  # Top location result
  sig { returns(T.nilable(GeocodedLocation)) }
  def top
    all.first
  end

  # The remaining location results
  sig { returns(T.nilable(T::Array[GeocodedLocation])) }
  def rest
    all[1..]
  end
end
