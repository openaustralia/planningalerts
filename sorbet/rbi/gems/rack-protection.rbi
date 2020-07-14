# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/rack-protection/all/rack-protection.rbi
#
# rack-protection-2.0.8.1

module Rack
end
module Rack::Protection
  def self.new(app, options = nil); end
end
class Rack::Protection::Base
  def accepts?(env); end
  def app; end
  def call(env); end
  def default_options; end
  def default_reaction(env); end
  def deny(env); end
  def drop_session(env); end
  def encrypt(value); end
  def html?(headers); end
  def initialize(app, options = nil); end
  def instrument(env); end
  def options; end
  def origin(env); end
  def random_string(secure = nil); end
  def react(env); end
  def referrer(env); end
  def report(env); end
  def safe?(env); end
  def secure_compare(a, b); end
  def self.default_options(options); end
  def self.default_reaction(reaction); end
  def session(env); end
  def session?(env); end
  def warn(env, message); end
end
class Rack::Protection::FrameOptions < Rack::Protection::Base
  def call(env); end
  def default_options; end
  def frame_options; end
end