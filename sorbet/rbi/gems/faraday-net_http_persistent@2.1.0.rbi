# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `faraday-net_http_persistent` gem.
# Please instead update this file by running `bin/tapioca gem faraday-net_http_persistent`.


# source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#5
module Faraday
  class << self
    # source://faraday/2.10.1/lib/faraday.rb#55
    def default_adapter; end

    # source://faraday/2.10.1/lib/faraday.rb#102
    def default_adapter=(adapter); end

    # source://faraday/2.10.1/lib/faraday.rb#59
    def default_adapter_options; end

    # source://faraday/2.10.1/lib/faraday.rb#59
    def default_adapter_options=(_arg0); end

    # source://faraday/2.10.1/lib/faraday.rb#120
    def default_connection; end

    # source://faraday/2.10.1/lib/faraday.rb#62
    def default_connection=(_arg0); end

    # source://faraday/2.10.1/lib/faraday.rb#127
    def default_connection_options; end

    # source://faraday/2.10.1/lib/faraday.rb#134
    def default_connection_options=(options); end

    # source://faraday/2.10.1/lib/faraday.rb#67
    def ignore_env_proxy; end

    # source://faraday/2.10.1/lib/faraday.rb#67
    def ignore_env_proxy=(_arg0); end

    # source://faraday/2.10.1/lib/faraday.rb#46
    def lib_path; end

    # source://faraday/2.10.1/lib/faraday.rb#46
    def lib_path=(_arg0); end

    # source://faraday/2.10.1/lib/faraday.rb#96
    def new(url = T.unsafe(nil), options = T.unsafe(nil), &block); end

    # source://faraday/2.10.1/lib/faraday.rb#107
    def respond_to_missing?(symbol, include_private = T.unsafe(nil)); end

    # source://faraday/2.10.1/lib/faraday.rb#42
    def root_path; end

    # source://faraday/2.10.1/lib/faraday.rb#42
    def root_path=(_arg0); end

    private

    # source://faraday/2.10.1/lib/faraday.rb#143
    def method_missing(name, *args, &block); end
  end
end

# source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#6
class Faraday::Adapter
  # source://faraday/2.10.1/lib/faraday/adapter.rb#28
  def initialize(_app = T.unsafe(nil), opts = T.unsafe(nil), &block); end

  # source://faraday/2.10.1/lib/faraday/adapter.rb#55
  def call(env); end

  # source://faraday/2.10.1/lib/faraday/adapter.rb#50
  def close; end

  # source://faraday/2.10.1/lib/faraday/adapter.rb#41
  def connection(env); end

  private

  # source://faraday/2.10.1/lib/faraday/adapter.rb#85
  def request_timeout(type, options); end

  # source://faraday/2.10.1/lib/faraday/adapter.rb#62
  def save_response(env, status, body, headers = T.unsafe(nil), reason_phrase = T.unsafe(nil), finished: T.unsafe(nil)); end
end

# Net::HTTP::Persistent adapter.
#
# source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#8
class Faraday::Adapter::NetHttpPersistent < ::Faraday::Adapter
  # @return [NetHttpPersistent] a new instance of NetHttpPersistent
  #
  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#34
  def initialize(app = T.unsafe(nil), opts = T.unsafe(nil), &block); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#39
  def call(env); end

  private

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#61
  def build_connection(env); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#95
  def configure_request(http, req); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#185
  def configure_ssl(http, ssl); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#69
  def create_request(env); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#209
  def encoded_body(http_response); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#196
  def http_set(http, attr, value); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#130
  def init_options; end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#122
  def net_http_connection(env); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#150
  def perform_request(http, env); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#136
  def proxy_uri(env); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#164
  def request_with_wrapped_block(http, env); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#85
  def save_http_response(env, http_response); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#115
  def ssl_cert_store(ssl); end

  # source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#200
  def ssl_verify_mode(ssl); end
end

# TODO (breaking): Enable this to make it consistent with net_http adapter.
#   See https://github.com/lostisland/faraday/issues/718#issuecomment-344549382
# exceptions << ::Net::OpenTimeout if defined?(::Net::OpenTimeout)
#
# source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#32
Faraday::Adapter::NetHttpPersistent::NET_HTTP_EXCEPTIONS = T.let(T.unsafe(nil), Array)

# source://faraday-net_http_persistent//lib/faraday/adapter/net_http_persistent.rb#176
Faraday::Adapter::NetHttpPersistent::SSL_CONFIGURATIONS = T.let(T.unsafe(nil), Hash)

# source://faraday-net_http_persistent//lib/faraday/net_http_persistent/version.rb#4
module Faraday::NetHttpPersistent; end

# source://faraday-net_http_persistent//lib/faraday/net_http_persistent/version.rb#5
Faraday::NetHttpPersistent::VERSION = T.let(T.unsafe(nil), String)
