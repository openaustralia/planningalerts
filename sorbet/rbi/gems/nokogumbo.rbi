# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: true
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/nokogumbo/all/nokogumbo.rbi
#
# nokogumbo-2.0.2

module Nokogumbo
  def self.fragment(arg0, arg1, arg2, arg3, arg4); end
  def self.parse(arg0, arg1, arg2, arg3); end
end
module Nokogiri
  def self.HTML5(string_or_io, url = nil, encoding = nil, **options, &block); end
end
module Nokogiri::HTML5
  def self.escape_text(text, encoding, attribute_mode); end
  def self.fragment(string, encoding = nil, **options); end
  def self.get(uri, options = nil); end
  def self.parse(string, url = nil, encoding = nil, **options, &block); end
  def self.prepend_newline?(node); end
  def self.read_and_encode(string, encoding); end
  def self.reencode(body, content_type = nil); end
  def self.serialize_node_internal(current_node, io, encoding, options); end
end
class Nokogiri::HTML5::Document < Nokogiri::HTML::Document
  def fragment(tags = nil); end
  def self.do_parse(string_or_io, url, encoding, options); end
  def self.parse(string_or_io, url = nil, encoding = nil, **options, &block); end
  def self.read_io(io, url = nil, encoding = nil, **options); end
  def self.read_memory(string, url = nil, encoding = nil, **options); end
  def to_xml(options = nil, &block); end
end
class Nokogiri::HTML5::DocumentFragment < Nokogiri::HTML::DocumentFragment
  def document; end
  def document=(arg0); end
  def errors; end
  def errors=(arg0); end
  def extract_params(params); end
  def initialize(doc, tags = nil, ctx = nil, options = nil); end
  def self.parse(tags, encoding = nil, options = nil); end
  def serialize(options = nil, &block); end
end
module Nokogiri::HTML5::Node
  def add_child_node_and_reparent_attrs(node); end
  def fragment(tags); end
  def inner_html(options = nil); end
  def write_to(io, *options); end
end
