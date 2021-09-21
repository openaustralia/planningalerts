# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/libv8-node-15.14.0.1-x86_64/all/libv8-node-15.14.0.1-x86_64.rbi
#
# libv8-node-15.14.0.1-x86_64-linux

module Libv8
end
module Libv8::Node
  def self.configure_makefile; end
end
module Libv8::Node::Paths
  def config; end
  def include_paths; end
  def object_paths; end
  def self.config; end
  def self.include_paths; end
  def self.object_paths; end
  def self.vendored_source_path; end
  def vendored_source_path; end
end
class Libv8::Node::Location
  def install!; end
  def self.load!; end
end
class Libv8::Node::Location::Vendor < Libv8::Node::Location
  def configure(context = nil); end
  def install!; end
  def verify_installation!; end
end
class Libv8::Node::Location::Vendor::HeaderNotFound < StandardError
end
class Libv8::Node::Location::Vendor::ArchiveNotFound < StandardError
  def initialize(filename); end
end
class Libv8::Node::Location::MkmfContext
  def incflags; end
  def ldflags; end
end