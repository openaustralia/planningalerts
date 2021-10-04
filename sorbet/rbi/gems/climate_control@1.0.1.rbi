# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `climate_control` gem.
# Please instead update this file by running `tapioca generate`.

# typed: true

module ClimateControl
  class << self
    def env; end
    def modify(environment_overrides, &block); end
  end
end

class ClimateControl::Environment
  extend(::Forwardable)

  def initialize; end

  def [](*args, &block); end
  def []=(*args, &block); end
  def delete(*args, &block); end
  def synchronize; end
  def to_hash(*args, &block); end

  private

  def env; end
end

class ClimateControl::Modifier
  def initialize(env, environment_overrides = T.unsafe(nil), &block); end

  def process; end

  private

  def cache_environment_after_block; end
  def clone_environment; end
  def copy_overrides_to_environment; end
  def delete_keys_that_do_not_belong; end
  def keys_changed_by_block; end
  def keys_to_remove; end
  def prepare_environment_for_block; end
  def revert_changed_keys; end
  def run_block; end
  def stringify_keys(env); end
end

class ClimateControl::Modifier::OverlappingKeysWithChangedValues
  def initialize(hash_1, hash_2); end

  def keys; end

  private

  def overlapping_keys; end
end

class ClimateControl::UnassignableValueError < ::ArgumentError
end

ClimateControl::VERSION = T.let(T.unsafe(nil), String)