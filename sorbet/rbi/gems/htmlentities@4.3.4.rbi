# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `htmlentities` gem.
# Please instead update this file by running `bin/tapioca gem htmlentities`.


# HTML entity encoding and decoding for Ruby
#
# source://htmlentities//lib/htmlentities/flavors.rb#1
class HTMLEntities
  # Create a new HTMLEntities coder for the specified flavor.
  # Available flavors are 'html4', 'expanded' and 'xhtml1' (the default).
  #
  # The only difference in functionality between html4 and xhtml1 is in the
  # handling of the apos (apostrophe) named entity, which is not defined in
  # HTML4.
  #
  # 'expanded' includes a large number of additional SGML entities drawn from
  #   ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MISC/SGML.TXT
  # it "maps SGML character entities from various public sets (namely, ISOamsa,
  # ISOamsb, ISOamsc, ISOamsn, ISOamso, ISOamsr, ISObox, ISOcyr1, ISOcyr2,
  # ISOdia, ISOgrk1, ISOgrk2, ISOgrk3, ISOgrk4, ISOlat1, ISOlat2, ISOnum,
  # ISOpub, ISOtech, HTMLspecial, HTMLsymbol) to corresponding Unicode
  # characters." (sgml.txt).
  #
  # 'expanded' is a strict superset of the XHTML entities: every xhtml named
  # entity encodes and decodes the same under :expanded as under :xhtml1
  #
  # @raise [UnknownFlavor]
  # @return [HTMLEntities] a new instance of HTMLEntities
  #
  # source://htmlentities//lib/htmlentities.rb#32
  def initialize(flavor = T.unsafe(nil)); end

  # Decode entities in a string into their UTF-8
  # equivalents. The string should already be in UTF-8 encoding.
  #
  # Unknown named entities will not be converted
  #
  # source://htmlentities//lib/htmlentities.rb#43
  def decode(source); end

  # Encode codepoints into their corresponding entities.  Various operations
  # are possible, and may be specified in order:
  #
  # :basic :: Convert the five XML entities ('"<>&)
  # :named :: Convert non-ASCII characters to their named HTML 4.01 equivalent
  # :decimal :: Convert non-ASCII characters to decimal entities (e.g. &#1234;)
  # :hexadecimal :: Convert non-ASCII characters to hexadecimal entities (e.g. # &#x12ab;)
  #
  # You can specify the commands in any order, but they will be executed in
  # the order listed above to ensure that entity ampersands are not
  # clobbered and that named entities are replaced before numeric ones.
  #
  # If no instructions are specified, :basic will be used.
  #
  # Examples:
  #   encode(str) - XML-safe
  #   encode(str, :basic, :decimal) - XML-safe and 7-bit clean
  #   encode(str, :basic, :named, :decimal) - 7-bit clean, with all
  #   non-ASCII characters replaced with their named entity where possible, and
  #   decimal equivalents otherwise.
  #
  # Note: It is the program's responsibility to ensure that the source
  # contains valid UTF-8 before calling this method.
  #
  # source://htmlentities//lib/htmlentities.rb#72
  def encode(source, *instructions); end
end

# source://htmlentities//lib/htmlentities/decoder.rb#2
class HTMLEntities::Decoder
  # @return [Decoder] a new instance of Decoder
  #
  # source://htmlentities//lib/htmlentities/decoder.rb#3
  def initialize(flavor); end

  # source://htmlentities//lib/htmlentities/decoder.rb#9
  def decode(source); end

  private

  # source://htmlentities//lib/htmlentities/decoder.rb#28
  def entity_regexp; end

  # source://htmlentities//lib/htmlentities/decoder.rb#24
  def prepare(string); end
end

# source://htmlentities//lib/htmlentities/encoder.rb#4
class HTMLEntities::Encoder
  # @return [Encoder] a new instance of Encoder
  #
  # source://htmlentities//lib/htmlentities/encoder.rb#7
  def initialize(flavor, instructions); end

  # source://htmlentities//lib/htmlentities/encoder.rb#15
  def encode(source); end

  private

  # source://htmlentities//lib/htmlentities/encoder.rb#40
  def basic_entity_regexp; end

  # source://htmlentities//lib/htmlentities/encoder.rb#73
  def build_basic_entity_encoder(instructions); end

  # source://htmlentities//lib/htmlentities/encoder.rb#88
  def build_extended_entity_encoder(instructions); end

  # @return [Boolean]
  #
  # source://htmlentities//lib/htmlentities/encoder.rb#36
  def contains_only_ascii?(string); end

  # source://htmlentities//lib/htmlentities/encoder.rb#106
  def encode_decimal(char); end

  # source://htmlentities//lib/htmlentities/encoder.rb#110
  def encode_hexadecimal(char); end

  # source://htmlentities//lib/htmlentities/encoder.rb#101
  def encode_named(char); end

  # source://htmlentities//lib/htmlentities/encoder.rb#44
  def extended_entity_regexp; end

  # source://htmlentities//lib/htmlentities/encoder.rb#28
  def minimize_encoding(string); end

  # source://htmlentities//lib/htmlentities/encoder.rb#24
  def prepare(string); end

  # source://htmlentities//lib/htmlentities/encoder.rb#52
  def replace_basic(string); end

  # source://htmlentities//lib/htmlentities/encoder.rb#56
  def replace_extended(string); end

  # source://htmlentities//lib/htmlentities/encoder.rb#114
  def reverse_map; end

  # source://htmlentities//lib/htmlentities/encoder.rb#60
  def validate_instructions(instructions); end
end

# source://htmlentities//lib/htmlentities/encoder.rb#5
HTMLEntities::Encoder::INSTRUCTIONS = T.let(T.unsafe(nil), Array)

# source://htmlentities//lib/htmlentities/flavors.rb#2
HTMLEntities::FLAVORS = T.let(T.unsafe(nil), Array)

# source://htmlentities//lib/htmlentities/encoder.rb#2
class HTMLEntities::InstructionError < ::RuntimeError; end

# source://htmlentities//lib/htmlentities/flavors.rb#3
HTMLEntities::MAPPINGS = T.let(T.unsafe(nil), Hash)

# source://htmlentities//lib/htmlentities/flavors.rb#4
HTMLEntities::SKIP_DUP_ENCODINGS = T.let(T.unsafe(nil), Hash)

# source://htmlentities//lib/htmlentities.rb#11
class HTMLEntities::UnknownFlavor < ::RuntimeError; end

# source://htmlentities//lib/htmlentities/version.rb#2
module HTMLEntities::VERSION; end

# source://htmlentities//lib/htmlentities/version.rb#3
HTMLEntities::VERSION::MAJOR = T.let(T.unsafe(nil), Integer)

# source://htmlentities//lib/htmlentities/version.rb#4
HTMLEntities::VERSION::MINOR = T.let(T.unsafe(nil), Integer)

# source://htmlentities//lib/htmlentities/version.rb#7
HTMLEntities::VERSION::STRING = T.let(T.unsafe(nil), String)

# source://htmlentities//lib/htmlentities/version.rb#5
HTMLEntities::VERSION::TINY = T.let(T.unsafe(nil), Integer)
