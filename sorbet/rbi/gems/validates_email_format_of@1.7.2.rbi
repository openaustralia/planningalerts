# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `validates_email_format_of` gem.
# Please instead update this file by running `bin/tapioca gem validates_email_format_of`.

# source://validates_email_format_of//lib/validates_email_format_of/active_model.rb#8
module ActiveModel
  class << self
    # source://activemodel/6.1.4.1/lib/active_model.rb#70
    def eager_load!; end

    # source://activemodel/6.1.4.1/lib/active_model/gem_version.rb#5
    def gem_version; end

    # source://activemodel/6.1.4.1/lib/active_model/version.rb#7
    def version; end
  end
end

# source://validates_email_format_of//lib/validates_email_format_of/active_model.rb#9
module ActiveModel::Validations
  include GeneratedInstanceMethods
  include ::ActiveSupport::Callbacks
  include ::ActiveModel::Validations::HelperMethods

  mixes_in_class_methods GeneratedClassMethods
  mixes_in_class_methods ::ActiveModel::Validations::ClassMethods
  mixes_in_class_methods ::ActiveModel::Callbacks
  mixes_in_class_methods ::ActiveSupport::Callbacks::ClassMethods
  mixes_in_class_methods ::ActiveSupport::DescendantsTracker
  mixes_in_class_methods ::ActiveModel::Translation
  mixes_in_class_methods ::ActiveModel::Validations::HelperMethods

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#301
  def errors; end

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#373
  def invalid?(context = T.unsafe(nil)); end

  def read_attribute_for_validation(*_arg0); end

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#334
  def valid?(context = T.unsafe(nil)); end

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#334
  def validate(context = T.unsafe(nil)); end

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#382
  def validate!(context = T.unsafe(nil)); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/with.rb#137
  def validates_with(*args, &block); end

  private

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#283
  def initialize_dup(other); end

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#410
  def raise_validation_error; end

  # source://activemodel/6.1.4.1/lib/active_model/validations.rb#405
  def run_validations!; end

  module GeneratedClassMethods
    def __callbacks; end
    def __callbacks=(value); end
    def __callbacks?; end
    def _validators; end
    def _validators=(value); end
    def _validators?; end
  end

  module GeneratedInstanceMethods
    def __callbacks; end
    def __callbacks?; end
    def _validators; end
    def _validators?; end
  end
end

# source://validates_email_format_of//lib/validates_email_format_of/active_model.rb#10
class ActiveModel::Validations::EmailFormatValidator < ::ActiveModel::EachValidator
  # source://validates_email_format_of//lib/validates_email_format_of/active_model.rb#11
  def validate_each(record, attribute, value); end
end

# source://validates_email_format_of//lib/validates_email_format_of/active_model.rb#18
module ActiveModel::Validations::HelperMethods
  # source://activemodel/6.1.4.1/lib/active_model/validations/absence.rb#28
  def validates_absence_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/acceptance.rb#108
  def validates_acceptance_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/confirmation.rb#75
  def validates_confirmation_of(*attr_names); end

  # source://validates_email_format_of//lib/validates_email_format_of/active_model.rb#19
  def validates_email_format_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/exclusion.rb#44
  def validates_exclusion_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/format.rb#108
  def validates_format_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/inclusion.rb#42
  def validates_inclusion_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/length.rb#122
  def validates_length_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/numericality.rb#198
  def validates_numericality_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/presence.rb#34
  def validates_presence_of(*attr_names); end

  # source://activemodel/6.1.4.1/lib/active_model/validations/length.rb#122
  def validates_size_of(*attr_names); end

  private

  # source://activemodel/6.1.4.1/lib/active_model/validations/helper_methods.rb#7
  def _merge_attributes(attr_names); end
end

# source://validates_email_format_of//lib/validates_email_format_of/version.rb#1
module ValidatesEmailFormatOf
  class << self
    # source://validates_email_format_of//lib/validates_email_format_of.rb#111
    def default_message; end

    # source://validates_email_format_of//lib/validates_email_format_of.rb#4
    def load_i18n_locales; end

    # source://validates_email_format_of//lib/validates_email_format_of.rb#234
    def validate_domain_part_syntax(domain); end

    # source://validates_email_format_of//lib/validates_email_format_of.rb#97
    def validate_email_domain(email, check_mx_timeout: T.unsafe(nil)); end

    # Validates whether the specified value is a valid email address.  Returns nil if the value is valid, otherwise returns an array
    # containing one or more validation error messages.
    #
    # Configuration options:
    # * <tt>message</tt> - A custom error message (default is: "does not appear to be valid")
    # * <tt>check_mx</tt> - Check for MX records (default is false)
    # * <tt>check_mx_timeout</tt> - Timeout in seconds for checking MX records before a `ResolvTimeout` is raised (default is 3)
    # * <tt>mx_message</tt> - A custom error message when an MX record validation fails (default is: "is not routable.")
    # * <tt>with</tt> The regex to use for validating the format of the email address (deprecated)
    # * <tt>local_length</tt> Maximum number of characters allowed in the local part (default is 64)
    # * <tt>domain_length</tt> Maximum number of characters allowed in the domain part (default is 255)
    # * <tt>generate_message</tt> Return the I18n key of the error message instead of the error message itself (default is false)
    #
    # source://validates_email_format_of//lib/validates_email_format_of.rb#127
    def validate_email_format(email, options = T.unsafe(nil)); end

    # source://validates_email_format_of//lib/validates_email_format_of.rb#169
    def validate_local_part_syntax(local); end
  end
end

# Characters that are allowed in to appear in the local part unquoted
# https://www.rfc-editor.org/rfc/rfc5322#section-3.2.3
#
# An addr-spec is a specific Internet identifier that contains a
# locally interpreted string followed by the at-sign character ("@",
# ASCII value 64) followed by an Internet domain.  The locally
# interpreted string is either a quoted-string or a dot-atom.  If the
# string can be represented as a dot-atom (that is, it contains no
# characters other than atext characters or "." surrounded by atext
# characters), then the dot-atom form SHOULD be used and the quoted-
# string form SHOULD NOT be used.  Comments and folding white space
# SHOULD NOT be used around the "@" in the addr-spec.
#
#   atext           =   ALPHA / DIGIT /
#                       "!" / "#" / "$" / "%" / "&" / "'" / "*" /
#                       "+" / "-" / "/" / "=" / "?" / "^" / "_" /
#                       "`" / "{" / "|" / "}" / "~"
#   dot-atom-text   =   1*atext *("." 1*atext)
#   dot-atom        =   [CFWS] dot-atom-text [CFWS]
#
# source://validates_email_format_of//lib/validates_email_format_of.rb#30
ValidatesEmailFormatOf::ATEXT = T.let(T.unsafe(nil), Regexp)

# Characters that are allowed to appear unquoted in comments
# https://www.rfc-editor.org/rfc/rfc5322#section-3.2.2
#
# ctext           =   %d33-39 / %d42-91 / %d93-126
# ccontent        =   ctext / quoted-pair / comment
# comment         =   "(" *([FWS] ccontent) [FWS] ")"
# CFWS            =   (1*([FWS] comment) [FWS]) / FWS
#
# source://validates_email_format_of//lib/validates_email_format_of.rb#39
ValidatesEmailFormatOf::CTEXT = T.let(T.unsafe(nil), Regexp)

# source://validates_email_format_of//lib/validates_email_format_of.rb#106
ValidatesEmailFormatOf::DEFAULT_MESSAGE = T.let(T.unsafe(nil), String)

# source://validates_email_format_of//lib/validates_email_format_of.rb#107
ValidatesEmailFormatOf::DEFAULT_MX_MESSAGE = T.let(T.unsafe(nil), String)

# From https://datatracker.ietf.org/doc/html/rfc1035#section-2.3.1
#
# > The labels must follow the rules for ARPANET host names.  They must
# > start with a letter, end with a letter or digit, and have as interior
# > characters only letters, digits, and hyphen.  There are also some
# > restrictions on the length.  Labels must be 63 characters or less.
#
# <label> | <subdomain> "." <label>
# <label> ::= <letter> [ [ <ldh-str> ] <let-dig> ]
# <ldh-str> ::= <let-dig-hyp> | <let-dig-hyp> <ldh-str>
# <let-dig-hyp> ::= <let-dig> | "-"
# <let-dig> ::= <letter> | <digit>
#
# Additionally, from https://datatracker.ietf.org/doc/html/rfc1123#section-2.1
#
# > One aspect of host name syntax is hereby changed: the
# > restriction on the first character is relaxed to allow either a
# > letter or a digit.  Host software MUST support this more liberal
# > syntax.
#
# source://validates_email_format_of//lib/validates_email_format_of.rb#80
ValidatesEmailFormatOf::DOMAIN_PART_LABEL = T.let(T.unsafe(nil), Regexp)

# From https://tools.ietf.org/id/draft-liman-tld-names-00.html#rfc.section.2
#
# > A TLD label MUST be at least two characters long and MAY be as long as 63 characters -
# > not counting any leading or trailing periods (.). It MUST consist of only ASCII characters
# > from the groups "letters" (A-Z), "digits" (0-9) and "hyphen" (-), and it MUST start with an
# > ASCII "letter", and it MUST NOT end with a "hyphen". Upper and lower case MAY be mixed at random,
# > since DNS lookups are case-insensitive.
#
# tldlabel = ALPHA *61(ldh) ld
# ldh      = ld / "-"
# ld       = ALPHA / DIGIT
# ALPHA    = %x41-5A / %x61-7A   ; A-Z / a-z
# DIGIT    = %x30-39             ; 0-9
#
# source://validates_email_format_of//lib/validates_email_format_of.rb#95
ValidatesEmailFormatOf::DOMAIN_PART_TLD = T.let(T.unsafe(nil), Regexp)

# source://validates_email_format_of//lib/validates_email_format_of.rb#108
ValidatesEmailFormatOf::ERROR_MESSAGE_I18N_KEY = T.let(T.unsafe(nil), Symbol)

# source://validates_email_format_of//lib/validates_email_format_of.rb#109
ValidatesEmailFormatOf::ERROR_MX_MESSAGE_I18N_KEY = T.let(T.unsafe(nil), Symbol)

# source://validates_email_format_of//lib/validates_email_format_of.rb#59
ValidatesEmailFormatOf::IP_OCTET = T.let(T.unsafe(nil), Regexp)

# https://www.rfc-editor.org/rfc/rfc5322#section-3.2.4
#
# Strings of characters that include characters other than those
# allowed in atoms can be represented in a quoted string format, where
# the characters are surrounded by quote (DQUOTE, ASCII value 34)
# characters.
#
# qtext           =   %d33 /             ; Printable US-ASCII
#                     %d35-91 /          ;  characters not including
#                     %d93-126 /         ;  "\" or the quote character
#                     obs-qtext
#
# qcontent        =   qtext / quoted-pair
# quoted-string   =   [CFWS]
#                     DQUOTE *([FWS] qcontent) [FWS] DQUOTE
#                     [CFWS]
#
# source://validates_email_format_of//lib/validates_email_format_of.rb#57
ValidatesEmailFormatOf::QTEXT = T.let(T.unsafe(nil), Regexp)

# source://validates_email_format_of//lib/validates_email_format_of/railtie.rb#2
class ValidatesEmailFormatOf::Railtie < ::Rails::Railtie; end

# source://validates_email_format_of//lib/validates_email_format_of/version.rb#2
ValidatesEmailFormatOf::VERSION = T.let(T.unsafe(nil), String)
