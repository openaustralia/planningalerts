# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `slack-notifier` gem.
# Please instead update this file by running `bin/tapioca gem slack-notifier`.


# source://slack-notifier//lib/slack-notifier/util/http_client.rb#5
module Slack; end

# source://slack-notifier//lib/slack-notifier/util/http_client.rb#6
class Slack::Notifier
  # @return [Notifier] a new instance of Notifier
  #
  # source://slack-notifier//lib/slack-notifier.rb#16
  def initialize(webhook_url, options = T.unsafe(nil), &block); end

  # source://slack-notifier//lib/slack-notifier.rb#26
  def config; end

  # Returns the value of attribute endpoint.
  #
  # source://slack-notifier//lib/slack-notifier.rb#14
  def endpoint; end

  # source://slack-notifier//lib/slack-notifier.rb#30
  def ping(message, options = T.unsafe(nil)); end

  # source://slack-notifier//lib/slack-notifier.rb#40
  def post(payload = T.unsafe(nil)); end

  private

  # source://slack-notifier//lib/slack-notifier.rb#55
  def middleware; end
end

# source://slack-notifier//lib/slack-notifier/util/http_client.rb#7
class Slack::Notifier::APIError < ::StandardError; end

# source://slack-notifier//lib/slack-notifier/config.rb#5
class Slack::Notifier::Config
  # @return [Config] a new instance of Config
  #
  # source://slack-notifier//lib/slack-notifier/config.rb#6
  def initialize; end

  # @raise [ArgumentError]
  #
  # source://slack-notifier//lib/slack-notifier/config.rb#24
  def defaults(new_defaults = T.unsafe(nil)); end

  # @raise [ArgumentError]
  #
  # source://slack-notifier//lib/slack-notifier/config.rb#17
  def http_client(client = T.unsafe(nil)); end

  # source://slack-notifier//lib/slack-notifier/config.rb#31
  def middleware(*args); end
end

# source://slack-notifier//lib/slack-notifier/payload_middleware.rb#5
class Slack::Notifier::PayloadMiddleware
  class << self
    # source://slack-notifier//lib/slack-notifier/payload_middleware.rb#11
    def register(middleware, name); end

    # source://slack-notifier//lib/slack-notifier/payload_middleware.rb#7
    def registry; end
  end
end

# source://slack-notifier//lib/slack-notifier/payload_middleware/at.rb#6
class Slack::Notifier::PayloadMiddleware::At < ::Slack::Notifier::PayloadMiddleware::Base
  # source://slack-notifier//lib/slack-notifier/payload_middleware/at.rb#11
  def call(payload = T.unsafe(nil)); end

  private

  # source://slack-notifier//lib/slack-notifier/payload_middleware/at.rb#25
  def at_cmd_char(at); end

  # source://slack-notifier//lib/slack-notifier/payload_middleware/at.rb#20
  def format_ats(ats); end
end

# source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#6
class Slack::Notifier::PayloadMiddleware::Base
  # @return [Base] a new instance of Base
  #
  # source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#23
  def initialize(notifier, opts = T.unsafe(nil)); end

  # @raise [NoMethodError]
  #
  # source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#28
  def call(_payload = T.unsafe(nil)); end

  # Returns the value of attribute notifier.
  #
  # source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#21
  def notifier; end

  # Returns the value of attribute options.
  #
  # source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#21
  def options; end

  class << self
    # source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#16
    def default_opts; end

    # source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#8
    def middleware_name(name); end

    # source://slack-notifier//lib/slack-notifier/payload_middleware/base.rb#12
    def options(default_opts); end
  end
end

# source://slack-notifier//lib/slack-notifier/payload_middleware/channels.rb#6
class Slack::Notifier::PayloadMiddleware::Channels < ::Slack::Notifier::PayloadMiddleware::Base
  # source://slack-notifier//lib/slack-notifier/payload_middleware/channels.rb#9
  def call(payload = T.unsafe(nil)); end
end

# source://slack-notifier//lib/slack-notifier/payload_middleware/format_attachments.rb#6
class Slack::Notifier::PayloadMiddleware::FormatAttachments < ::Slack::Notifier::PayloadMiddleware::Base
  # source://slack-notifier//lib/slack-notifier/payload_middleware/format_attachments.rb#11
  def call(payload = T.unsafe(nil)); end

  private

  # source://slack-notifier//lib/slack-notifier/payload_middleware/format_attachments.rb#32
  def wrap_array(object); end
end

# source://slack-notifier//lib/slack-notifier/payload_middleware/format_message.rb#6
class Slack::Notifier::PayloadMiddleware::FormatMessage < ::Slack::Notifier::PayloadMiddleware::Base
  # source://slack-notifier//lib/slack-notifier/payload_middleware/format_message.rb#11
  def call(payload = T.unsafe(nil)); end
end

# source://slack-notifier//lib/slack-notifier/payload_middleware/stack.rb#6
class Slack::Notifier::PayloadMiddleware::Stack
  # @return [Stack] a new instance of Stack
  #
  # source://slack-notifier//lib/slack-notifier/payload_middleware/stack.rb#10
  def initialize(notifier); end

  # source://slack-notifier//lib/slack-notifier/payload_middleware/stack.rb#28
  def call(payload = T.unsafe(nil)); end

  # Returns the value of attribute notifier.
  #
  # source://slack-notifier//lib/slack-notifier/payload_middleware/stack.rb#7
  def notifier; end

  # source://slack-notifier//lib/slack-notifier/payload_middleware/stack.rb#15
  def set(*middlewares); end

  # Returns the value of attribute stack.
  #
  # source://slack-notifier//lib/slack-notifier/payload_middleware/stack.rb#7
  def stack; end

  private

  # source://slack-notifier//lib/slack-notifier/payload_middleware/stack.rb#40
  def as_array(args); end
end

# source://slack-notifier//lib/slack-notifier/util/http_client.rb#9
module Slack::Notifier::Util; end

# source://slack-notifier//lib/slack-notifier/util/escape.rb#6
module Slack::Notifier::Util::Escape
  class << self
    # source://slack-notifier//lib/slack-notifier/util/escape.rb#10
    def html(string); end
  end
end

# source://slack-notifier//lib/slack-notifier/util/escape.rb#7
Slack::Notifier::Util::Escape::HTML_REGEXP = T.let(T.unsafe(nil), Regexp)

# source://slack-notifier//lib/slack-notifier/util/escape.rb#8
Slack::Notifier::Util::Escape::HTML_REPLACE = T.let(T.unsafe(nil), Hash)

# source://slack-notifier//lib/slack-notifier/util/http_client.rb#10
class Slack::Notifier::Util::HTTPClient
  # @return [HTTPClient] a new instance of HTTPClient
  #
  # source://slack-notifier//lib/slack-notifier/util/http_client.rb#19
  def initialize(uri, params); end

  # source://slack-notifier//lib/slack-notifier/util/http_client.rb#26
  def call; end

  # Returns the value of attribute http_options.
  #
  # source://slack-notifier//lib/slack-notifier/util/http_client.rb#17
  def http_options; end

  # Returns the value of attribute params.
  #
  # source://slack-notifier//lib/slack-notifier/util/http_client.rb#17
  def params; end

  # Returns the value of attribute uri.
  #
  # source://slack-notifier//lib/slack-notifier/util/http_client.rb#17
  def uri; end

  private

  # source://slack-notifier//lib/slack-notifier/util/http_client.rb#47
  def http_obj; end

  # source://slack-notifier//lib/slack-notifier/util/http_client.rb#40
  def request_obj; end

  class << self
    # source://slack-notifier//lib/slack-notifier/util/http_client.rb#12
    def post(uri, params); end
  end
end

# source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#6
class Slack::Notifier::Util::LinkFormatter
  # @return [LinkFormatter] a new instance of LinkFormatter
  #
  # source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#38
  def initialize(string, formats: T.unsafe(nil)); end

  # Returns the value of attribute formats.
  #
  # source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#36
  def formats; end

  # source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#44
  def formatted; end

  private

  # source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#72
  def slack_link(link, text = T.unsafe(nil)); end

  # source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#56
  def sub_html_links(string); end

  # source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#64
  def sub_markdown_links(string); end

  class << self
    # source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#31
    def format(string, opts = T.unsafe(nil)); end
  end
end

# http://rubular.com/r/19cNXW5qbH
#
# source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#8
Slack::Notifier::Util::LinkFormatter::HTML_PATTERN = T.let(T.unsafe(nil), Regexp)

# Attempt at only matching pairs of parens per
# the markdown spec http://spec.commonmark.org/0.27/#links
#
# http://rubular.com/r/y107aevxqT
#
# source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#24
Slack::Notifier::Util::LinkFormatter::MARKDOWN_PATTERN = T.let(T.unsafe(nil), Regexp)

# the path portion of a url can contain these characters
#
# source://slack-notifier//lib/slack-notifier/util/link_formatter.rb#18
Slack::Notifier::Util::LinkFormatter::VALID_PATH_CHARS = T.let(T.unsafe(nil), String)
