# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/ethon/all/ethon.rbi
#
# ethon-0.12.0

module Ethon
  extend Ethon::Loggable
end
module Ethon::Libc
  def free(*arg0); end
  def getdtablesize(*arg0); end
  def self.free(*arg0); end
  def self.getdtablesize(*arg0); end
  def self.windows?; end
  extend FFI::Library
end
module Ethon::Curls
end
module Ethon::Curls::Codes
  def easy_codes; end
  def multi_codes; end
end
module Ethon::Curls::Options
  def easy_options(rt); end
  def multi_options(rt); end
  def self.option(ftype, name, type, num, opts = nil); end
  def self.option_alias(ftype, name, *aliases); end
  def self.option_type(type); end
  def set_option(option, value, handle, type = nil); end
end
module Ethon::Curls::Infos
  def debug_info_types; end
  def get_info_double(option, handle); end
  def get_info_long(option, handle); end
  def get_info_string(option, handle); end
  def info_types; end
  def infos; end
end
module Ethon::Curls::FormOptions
  def form_options; end
end
module Ethon::Curls::Messages
  def msg_codes; end
end
module Ethon::Curls::Functions
  def self.extended(base); end
end
module Ethon::Curl
  def easy_cleanup(*arg0); end
  def easy_duphandle(*arg0); end
  def easy_escape(*arg0); end
  def easy_getinfo(*arg0); end
  def easy_init(*arg0); end
  def easy_perform(*arg0); end
  def easy_reset(*arg0); end
  def easy_setopt_callback(*arg0); end
  def easy_setopt_debug_callback(*arg0); end
  def easy_setopt_ffipointer(*arg0); end
  def easy_setopt_long(*arg0); end
  def easy_setopt_off_t(*arg0); end
  def easy_setopt_progress_callback(*arg0); end
  def easy_setopt_string(*arg0); end
  def easy_strerror(*arg0); end
  def formadd(*args); end
  def formfree(*arg0); end
  def free(*arg0); end
  def global_cleanup(*arg0); end
  def global_init(*arg0); end
  def multi_add_handle(*arg0); end
  def multi_cleanup(*arg0); end
  def multi_fdset(*arg0); end
  def multi_info_read(*arg0); end
  def multi_init(*arg0); end
  def multi_perform(*arg0); end
  def multi_remove_handle(*arg0); end
  def multi_setopt_callback(*arg0); end
  def multi_setopt_ffipointer(*arg0); end
  def multi_setopt_long(*arg0); end
  def multi_setopt_off_t(*arg0); end
  def multi_setopt_string(*arg0); end
  def multi_strerror(*arg0); end
  def multi_timeout(*arg0); end
  def select(*arg0); end
  def self.cleanup; end
  def self.easy_cleanup(*arg0); end
  def self.easy_duphandle(*arg0); end
  def self.easy_escape(*arg0); end
  def self.easy_getinfo(*arg0); end
  def self.easy_init(*arg0); end
  def self.easy_perform(*arg0); end
  def self.easy_reset(*arg0); end
  def self.easy_setopt_callback(*arg0); end
  def self.easy_setopt_debug_callback(*arg0); end
  def self.easy_setopt_ffipointer(*arg0); end
  def self.easy_setopt_long(*arg0); end
  def self.easy_setopt_off_t(*arg0); end
  def self.easy_setopt_progress_callback(*arg0); end
  def self.easy_setopt_string(*arg0); end
  def self.easy_strerror(*arg0); end
  def self.formadd(*args); end
  def self.formfree(*arg0); end
  def self.free(*arg0); end
  def self.global_cleanup(*arg0); end
  def self.global_init(*arg0); end
  def self.init; end
  def self.multi_add_handle(*arg0); end
  def self.multi_cleanup(*arg0); end
  def self.multi_fdset(*arg0); end
  def self.multi_info_read(*arg0); end
  def self.multi_init(*arg0); end
  def self.multi_perform(*arg0); end
  def self.multi_remove_handle(*arg0); end
  def self.multi_setopt_callback(*arg0); end
  def self.multi_setopt_ffipointer(*arg0); end
  def self.multi_setopt_long(*arg0); end
  def self.multi_setopt_off_t(*arg0); end
  def self.multi_setopt_string(*arg0); end
  def self.multi_strerror(*arg0); end
  def self.multi_timeout(*arg0); end
  def self.select(*arg0); end
  def self.slist_append(*arg0); end
  def self.slist_free_all(*arg0); end
  def self.version(*arg0); end
  def self.version_info(*arg0); end
  def self.windows?; end
  def slist_append(*arg0); end
  def slist_free_all(*arg0); end
  def version(*arg0); end
  def version_info(*arg0); end
  extend Ethon::Curls::Codes
  extend Ethon::Curls::FormOptions
  extend Ethon::Curls::Functions
  extend Ethon::Curls::Infos
  extend Ethon::Curls::Messages
  extend Ethon::Curls::Options
  extend FFI::Library
end
class Ethon::Curl::MsgData < FFI::Union
end
class Ethon::Curl::Msg < FFI::Struct
end
class Ethon::Curl::VersionInfoData < FFI::Struct
end
class Ethon::Curl::FDSet < FFI::Struct
  def clear; end
end
class Ethon::Curl::Timeval < FFI::Struct
end
class Ethon::Easy
  def debug_info; end
  def debug_info=(arg0); end
  def dup; end
  def escape(value); end
  def initialize(options = nil); end
  def log_inspect; end
  def mirror; end
  def reset; end
  def response_body; end
  def response_body=(arg0); end
  def response_headers; end
  def response_headers=(arg0); end
  def return_code; end
  def return_code=(arg0); end
  def set_attributes(options); end
  def to_hash; end
  extend Ethon::Easy::Features
  include Ethon::Easy::Callbacks
  include Ethon::Easy::Header
  include Ethon::Easy::Http
  include Ethon::Easy::Informations
  include Ethon::Easy::Operations
  include Ethon::Easy::Options
  include Ethon::Easy::ResponseCallbacks
end
module Ethon::Easy::Informations
  def appconnect_time; end
  def connect_time; end
  def effective_url; end
  def httpauth_avail; end
  def namelookup_time; end
  def pretransfer_time; end
  def primary_ip; end
  def redirect_count; end
  def redirect_time; end
  def request_size; end
  def response_code; end
  def starttransfer_time; end
  def supports_zlib?; end
  def total_time; end
end
module Ethon::Easy::Features
  def supports_asynch_dns?; end
  def supports_timeout_ms?; end
  def supports_zlib?; end
end
module Ethon::Easy::Callbacks
  def body_write_callback; end
  def debug_callback; end
  def header_write_callback; end
  def progress_callback; end
  def read_callback; end
  def self.included(base); end
  def set_callbacks; end
  def set_progress_callback; end
  def set_read_callback(body); end
end
module Ethon::Easy::Options
  def accept_encoding=(value); end
  def accepttimeout_ms=(value); end
  def address_scope=(value); end
  def append=(value); end
  def autoreferer=(value); end
  def buffersize=(value); end
  def cainfo=(value); end
  def capath=(value); end
  def certinfo=(value); end
  def chunk_bgn_function(&block); end
  def chunk_bgn_function=(value); end
  def chunk_data=(value); end
  def chunk_end_function(&block); end
  def chunk_end_function=(value); end
  def closesocketdata=(value); end
  def closesocketfunction(&block); end
  def closesocketfunction=(value); end
  def connect_only=(value); end
  def connecttimeout=(value); end
  def connecttimeout_ms=(value); end
  def conv_from_network_function(&block); end
  def conv_from_network_function=(value); end
  def conv_from_utf8_function(&block); end
  def conv_from_utf8_function=(value); end
  def conv_to_network_function(&block); end
  def conv_to_network_function=(value); end
  def cookie=(value); end
  def cookiefile=(value); end
  def cookiejar=(value); end
  def cookielist=(value); end
  def cookiesession=(value); end
  def copypostfields=(value); end
  def crlf=(value); end
  def crlfile=(value); end
  def customrequest=(value); end
  def debugdata=(value); end
  def debugfunction=(value); end
  def dirlistonly=(value); end
  def dns_cache_timeout=(value); end
  def dns_interface=(value); end
  def dns_local_ip4=(value); end
  def dns_servers=(value); end
  def dns_use_global_cache=(value); end
  def egdsocket=(value); end
  def encoding=(value); end
  def errorbuffer=(value); end
  def escape=(b); end
  def escape?; end
  def failonerror=(value); end
  def file=(value); end
  def filetime=(value); end
  def fnmatch_data=(value); end
  def fnmatch_function(&block); end
  def fnmatch_function=(value); end
  def followlocation=(value); end
  def forbid_reuse=(value); end
  def fresh_connect=(value); end
  def ftp_account=(value); end
  def ftp_alternative_to_user=(value); end
  def ftp_create_missing_dirs=(value); end
  def ftp_filemethod=(value); end
  def ftp_response_timeout=(value); end
  def ftp_skip_pasv_ip=(value); end
  def ftp_ssl=(value); end
  def ftp_ssl_ccc=(value); end
  def ftp_use_eprt=(value); end
  def ftp_use_epsv=(value); end
  def ftp_use_pret=(value); end
  def ftpappend=(value); end
  def ftplistonly=(value); end
  def ftpport=(value); end
  def ftpsslauth=(value); end
  def gssapi_delegation=(value); end
  def header=(value); end
  def headerdata=(value); end
  def headerfunction(&block); end
  def headerfunction=(value); end
  def http200aliases=(value); end
  def http_content_decoding=(value); end
  def http_transfer_decoding=(value); end
  def http_version=(value); end
  def httpauth=(value); end
  def httpget=(value); end
  def httpheader=(value); end
  def httppost=(value); end
  def httpproxytunnel=(value); end
  def ignore_content_length=(value); end
  def infile=(value); end
  def infilesize=(value); end
  def infilesize_large=(value); end
  def interface=(value); end
  def interleavedata=(value); end
  def interleavefunction(&block); end
  def interleavefunction=(value); end
  def ioctldata=(value); end
  def ioctlfunction(&block); end
  def ioctlfunction=(value); end
  def ipresolve=(value); end
  def issuercert=(value); end
  def keypasswd=(value); end
  def khstat=(value); end
  def krb4level=(value); end
  def krblevel=(value); end
  def localport=(value); end
  def localportrange=(value); end
  def low_speed_limit=(value); end
  def low_speed_time=(value); end
  def mail_auth=(value); end
  def mail_from=(value); end
  def mail_rcpt=(value); end
  def max_recv_speed_large=(value); end
  def max_send_speed_large=(value); end
  def maxconnects=(value); end
  def maxfilesize=(value); end
  def maxfilesize_large=(value); end
  def maxredirs=(value); end
  def multipart=(b); end
  def multipart?; end
  def netrc=(value); end
  def netrc_file=(value); end
  def new_directory_perms=(value); end
  def new_file_perms=(value); end
  def nobody=(value); end
  def noprogress=(value); end
  def noproxy=(value); end
  def nosignal=(value); end
  def opensocketdata=(value); end
  def opensocketfunction(&block); end
  def opensocketfunction=(value); end
  def password=(value); end
  def pipewait=(value); end
  def port=(value); end
  def post301=(value); end
  def post=(value); end
  def postfields=(value); end
  def postfieldsize=(value); end
  def postfieldsize_large=(value); end
  def postquote=(value); end
  def postredir=(value); end
  def prequote=(value); end
  def private=(value); end
  def progressdata=(value); end
  def progressfunction=(value); end
  def protocols=(value); end
  def proxy=(value); end
  def proxy_transfer_mode=(value); end
  def proxyauth=(value); end
  def proxypassword=(value); end
  def proxyport=(value); end
  def proxytype=(value); end
  def proxyusername=(value); end
  def proxyuserpwd=(value); end
  def put=(value); end
  def quote=(value); end
  def random_file=(value); end
  def range=(value); end
  def readdata=(value); end
  def readfunction(&block); end
  def readfunction=(value); end
  def redir_protocols=(value); end
  def referer=(value); end
  def resolve=(value); end
  def resume_from=(value); end
  def resume_from_large=(value); end
  def rtsp_client_cseq=(value); end
  def rtsp_request=(value); end
  def rtsp_server_cseq=(value); end
  def rtsp_session_id=(value); end
  def rtsp_stream_uri=(value); end
  def rtsp_transport=(value); end
  def rtspheader=(value); end
  def sasl_ir=(value); end
  def seekdata=(value); end
  def seekfunction(&block); end
  def seekfunction=(value); end
  def server_response_timeout=(value); end
  def share=(value); end
  def sockoptdata=(value); end
  def sockoptfunction(&block); end
  def sockoptfunction=(value); end
  def socks5_gssapi_nec=(value); end
  def socks5_gssapi_service=(value); end
  def ssh_auth_types=(value); end
  def ssh_host_public_key_md5=(value); end
  def ssh_keydata=(value); end
  def ssh_keyfunction(&block); end
  def ssh_keyfunction=(value); end
  def ssh_knownhosts=(value); end
  def ssh_private_keyfile=(value); end
  def ssh_public_keyfile=(value); end
  def ssl_cipher_list=(value); end
  def ssl_ctx_data=(value); end
  def ssl_ctx_function(&block); end
  def ssl_ctx_function=(value); end
  def ssl_options=(value); end
  def ssl_sessionid_cache=(value); end
  def ssl_verifyhost=(value); end
  def ssl_verifypeer=(value); end
  def sslcert=(value); end
  def sslcertpasswd=(value); end
  def sslcerttype=(value); end
  def sslengine=(value); end
  def sslengine_default=(value); end
  def sslkey=(value); end
  def sslkeypasswd=(value); end
  def sslkeytype=(value); end
  def sslversion=(value); end
  def stderr=(value); end
  def tcp_keepalive=(value); end
  def tcp_keepidle=(value); end
  def tcp_keepintvl=(value); end
  def tcp_nodelay=(value); end
  def telnetoptions=(value); end
  def tftp_blksize=(value); end
  def timecondition=(value); end
  def timeout=(value); end
  def timeout_ms=(value); end
  def timevalue=(value); end
  def tlsauth_password=(value); end
  def tlsauth_type=(value); end
  def tlsauth_username=(value); end
  def transfer_encoding=(value); end
  def transfertext=(value); end
  def unix_socket=(value); end
  def unix_socket_path=(value); end
  def unrestricted_auth=(value); end
  def upload=(value); end
  def url; end
  def url=(value); end
  def use_ssl=(value); end
  def useragent=(value); end
  def username=(value); end
  def userpwd=(value); end
  def verbose=(value); end
  def wildcardmatch=(value); end
  def writedata=(value); end
  def writefunction(&block); end
  def writefunction=(value); end
  def writeheader=(value); end
  def xferinfodata=(value); end
  def xferinfofunction=(value); end
end
module Ethon::Easy::Header
  def compose_header(key, value); end
  def header_list; end
  def headers; end
  def headers=(headers); end
end
module Ethon::Easy::Util
  def escape_zero_byte(value); end
  extend Ethon::Easy::Util
end
module Ethon::Easy::Queryable
  def build_query_pairs(hash); end
  def empty?; end
  def encode_hash_pairs(h, prefix, pairs); end
  def encode_indexed_array_pairs(h, prefix, pairs); end
  def encode_multi_array_pairs(h, prefix, pairs); end
  def encode_rack_array_pairs(h, prefix, pairs); end
  def file_info(file); end
  def mime_type(filename); end
  def pairs_for(v, key, pairs); end
  def query_pairs; end
  def recursively_generate_pairs(h, prefix, pairs); end
  def self.included(base); end
  def to_s; end
end
class Ethon::Easy::Params
  def escape; end
  def escape=(arg0); end
  def initialize(easy, params); end
  def params_encoding; end
  def params_encoding=(arg0); end
  include Ethon::Easy::Queryable
  include Ethon::Easy::Util
end
class Ethon::Easy::Form
  def escape; end
  def escape=(arg0); end
  def first; end
  def form_add(name, content); end
  def initialize(easy, params, multipart = nil); end
  def last; end
  def materialize; end
  def multipart?; end
  def params_encoding; end
  def params_encoding=(arg0); end
  def setup_garbage_collection; end
  include Ethon::Easy::Queryable
  include Ethon::Easy::Util
end
module Ethon::Easy::Http
  def fabricate(url, action_name, options); end
  def http_request(url, action_name, options = nil); end
end
module Ethon::Easy::Http::Putable
  def set_form(easy); end
end
module Ethon::Easy::Http::Postable
  def set_form(easy); end
end
module Ethon::Easy::Http::Actionable
  def form; end
  def initialize(url, options); end
  def options; end
  def params; end
  def params_encoding; end
  def parse_options(options); end
  def query_options; end
  def set_form(easy); end
  def set_params(easy); end
  def setup(easy); end
  def url; end
end
class Ethon::Easy::Http::Post
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Postable
end
class Ethon::Easy::Http::Get
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Postable
end
class Ethon::Easy::Http::Head
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Postable
end
class Ethon::Easy::Http::Put
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Putable
end
class Ethon::Easy::Http::Delete
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Postable
end
class Ethon::Easy::Http::Patch
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Postable
end
class Ethon::Easy::Http::Options
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Postable
end
class Ethon::Easy::Http::Custom
  def initialize(verb, url, options); end
  def setup(easy); end
  include Ethon::Easy::Http::Actionable
  include Ethon::Easy::Http::Postable
end
module Ethon::Easy::Operations
  def cleanup; end
  def handle; end
  def handle=(h); end
  def perform; end
  def prepare; end
end
module Ethon::Easy::ResponseCallbacks
  def body(chunk); end
  def complete; end
  def headers; end
  def on_body(&block); end
  def on_complete(&block); end
  def on_headers(&block); end
  def on_progress(&block); end
  def progress(dltotal, dlnow, ultotal, ulnow); end
end
class Ethon::Easy::DebugInfo
  def add(type, message); end
  def data_in; end
  def data_out; end
  def header_in; end
  def header_out; end
  def initialize; end
  def messages_for(type); end
  def ssl_data_in; end
  def ssl_data_out; end
  def text; end
  def to_a; end
  def to_h; end
end
class Ethon::Easy::DebugInfo::Message
  def initialize(type, message); end
  def message; end
  def type; end
end
class Ethon::Easy::Mirror
  def appconnect_time; end
  def connect_time; end
  def debug_info; end
  def effective_url; end
  def httpauth_avail; end
  def initialize(options = nil); end
  def log_informations; end
  def namelookup_time; end
  def options; end
  def pretransfer_time; end
  def primary_ip; end
  def redirect_count; end
  def redirect_time; end
  def request_size; end
  def response_body; end
  def response_code; end
  def response_headers; end
  def return_code; end
  def self.from_easy(easy); end
  def starttransfer_time; end
  def to_hash; end
  def total_time; end
end
module Ethon::Errors
end
class Ethon::Errors::EthonError < StandardError
end
class Ethon::Errors::GlobalInit < Ethon::Errors::EthonError
  def initialize; end
end
class Ethon::Errors::MultiTimeout < Ethon::Errors::EthonError
  def initialize(code); end
end
class Ethon::Errors::MultiFdset < Ethon::Errors::EthonError
  def initialize(code); end
end
class Ethon::Errors::MultiAdd < Ethon::Errors::EthonError
  def initialize(code, easy); end
end
class Ethon::Errors::MultiRemove < Ethon::Errors::EthonError
  def initialize(code, easy); end
end
class Ethon::Errors::Select < Ethon::Errors::EthonError
  def initialize(errno); end
end
class Ethon::Errors::InvalidOption < Ethon::Errors::EthonError
  def initialize(option); end
end
class Ethon::Errors::InvalidValue < Ethon::Errors::EthonError
  def initialize(option, value); end
end
module Ethon::Loggable
  def default_logger; end
  def logger; end
  def logger=(logger); end
  def rails_logger; end
end
class Ethon::Multi
  def initialize(options = nil); end
  def set_attributes(options); end
  include Ethon::Multi::Operations
  include Ethon::Multi::Options
  include Ethon::Multi::Stack
end
module Ethon::Multi::Stack
  def add(easy); end
  def delete(easy); end
  def easy_handles; end
end
module Ethon::Multi::Operations
  def check; end
  def get_timeout; end
  def handle; end
  def init_vars; end
  def ongoing?; end
  def perform; end
  def prepare; end
  def reset_fds; end
  def run; end
  def running_count; end
  def set_fds(timeout); end
  def trigger(running_count_pointer); end
end
module Ethon::Multi::Options
  def max_total_connections=(value); end
  def maxconnects=(value); end
  def pipelining=(value); end
  def socketdata=(value); end
  def socketfunction=(value); end
  def timerdata=(value); end
  def timerfunction=(value); end
  def value_for(value, type, option = nil); end
end