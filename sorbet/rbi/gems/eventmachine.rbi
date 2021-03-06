# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/eventmachine/all/eventmachine.rbi
#
# eventmachine-1.2.7

module EventMachine
  def add_oneshot_timer(arg0); end
  def attach_fd(arg0, arg1); end
  def attach_sd(arg0); end
  def bind_connect_server(arg0, arg1, arg2, arg3); end
  def close_connection(arg0, arg1); end
  def connect_server(arg0, arg1); end
  def connect_unix_server(arg0); end
  def connection_paused?(arg0); end
  def current_time; end
  def detach_fd(arg0); end
  def epoll; end
  def epoll=(arg0); end
  def epoll?; end
  def get_cipher_bits(arg0); end
  def get_cipher_name(arg0); end
  def get_cipher_protocol(arg0); end
  def get_comm_inactivity_timeout(arg0); end
  def get_connection_count; end
  def get_file_descriptor(arg0); end
  def get_heartbeat_interval; end
  def get_idle_time(arg0); end
  def get_max_timer_count; end
  def get_peer_cert(arg0); end
  def get_peername(arg0); end
  def get_pending_connect_timeout(arg0); end
  def get_proxied_bytes(arg0); end
  def get_simultaneous_accept_count; end
  def get_sni_hostname(arg0); end
  def get_sock_opt(arg0, arg1, arg2); end
  def get_sockname(arg0); end
  def get_subprocess_pid(arg0); end
  def get_subprocess_status(arg0); end
  def initialize_event_machine; end
  def invoke_popen(arg0); end
  def is_notify_readable(arg0); end
  def is_notify_writable(arg0); end
  def kqueue; end
  def kqueue=(arg0); end
  def kqueue?; end
  def library_type; end
  def num_close_scheduled; end
  def open_udp_socket(arg0, arg1); end
  def pause_connection(arg0); end
  def read_keyboard; end
  def release_machine; end
  def report_connection_error_status(arg0); end
  def resume_connection(arg0); end
  def run_machine; end
  def run_machine_once; end
  def run_machine_without_threads; end
  def self.Callback(object = nil, method = nil, &blk); end
  def self._open_file_for_writing(filename, handler = nil); end
  def self.add_oneshot_timer(arg0); end
  def self.add_periodic_timer(*args, &block); end
  def self.add_shutdown_hook(&block); end
  def self.add_timer(*args, &block); end
  def self.attach(io, handler = nil, *args, &blk); end
  def self.attach_fd(arg0, arg1); end
  def self.attach_io(io, watch_mode, handler = nil, *args); end
  def self.attach_sd(arg0); end
  def self.attach_server(sock, handler = nil, *args, &block); end
  def self.bind_connect(bind_addr, bind_port, server, port = nil, handler = nil, *args); end
  def self.bind_connect_server(arg0, arg1, arg2, arg3); end
  def self.cancel_timer(timer_or_sig); end
  def self.cleanup_machine; end
  def self.close_connection(arg0, arg1); end
  def self.connect(server, port = nil, handler = nil, *args, &blk); end
  def self.connect_server(arg0, arg1); end
  def self.connect_unix_domain(socketname, *args, &blk); end
  def self.connect_unix_server(arg0); end
  def self.connection_count; end
  def self.connection_paused?(arg0); end
  def self.current_time; end
  def self.defer(op = nil, callback = nil, errback = nil, &blk); end
  def self.defers_finished?; end
  def self.detach_fd(arg0); end
  def self.disable_proxy(from); end
  def self.enable_proxy(from, to, bufsize = nil, length = nil); end
  def self.epoll; end
  def self.epoll=(arg0); end
  def self.epoll?; end
  def self.error_handler(cb = nil, &blk); end
  def self.event_callback(conn_binding, opcode, data); end
  def self.fork_reactor(&block); end
  def self.get_cipher_bits(arg0); end
  def self.get_cipher_name(arg0); end
  def self.get_cipher_protocol(arg0); end
  def self.get_comm_inactivity_timeout(arg0); end
  def self.get_connection_count; end
  def self.get_file_descriptor(arg0); end
  def self.get_heartbeat_interval; end
  def self.get_idle_time(arg0); end
  def self.get_max_timer_count; end
  def self.get_max_timers; end
  def self.get_peer_cert(arg0); end
  def self.get_peername(arg0); end
  def self.get_pending_connect_timeout(arg0); end
  def self.get_proxied_bytes(arg0); end
  def self.get_simultaneous_accept_count; end
  def self.get_sni_hostname(arg0); end
  def self.get_sock_opt(arg0, arg1, arg2); end
  def self.get_sockname(arg0); end
  def self.get_subprocess_pid(arg0); end
  def self.get_subprocess_status(arg0); end
  def self.heartbeat_interval; end
  def self.heartbeat_interval=(time); end
  def self.initialize_event_machine; end
  def self.invoke_popen(arg0); end
  def self.is_notify_readable(arg0); end
  def self.is_notify_writable(arg0); end
  def self.klass_from_handler(klass = nil, handler = nil, *args); end
  def self.kqueue; end
  def self.kqueue=(arg0); end
  def self.kqueue?; end
  def self.library_type; end
  def self.next_tick(pr = nil, &block); end
  def self.num_close_scheduled; end
  def self.open_datagram_socket(address, port, handler = nil, *args); end
  def self.open_keyboard(handler = nil, *args); end
  def self.open_udp_socket(arg0, arg1); end
  def self.pause_connection(arg0); end
  def self.popen(cmd, handler = nil, *args); end
  def self.reactor_running?; end
  def self.reactor_thread; end
  def self.reactor_thread?; end
  def self.read_keyboard; end
  def self.reconnect(server, port, handler); end
  def self.release_machine; end
  def self.report_connection_error_status(arg0); end
  def self.resume_connection(arg0); end
  def self.run(blk = nil, tail = nil, &block); end
  def self.run_block(&block); end
  def self.run_deferred_callbacks; end
  def self.run_machine; end
  def self.run_machine_once; end
  def self.run_machine_without_threads; end
  def self.schedule(*a, &b); end
  def self.send_data(arg0, arg1, arg2); end
  def self.send_datagram(arg0, arg1, arg2, arg3, arg4); end
  def self.send_file_data(arg0, arg1); end
  def self.set_comm_inactivity_timeout(arg0, arg1); end
  def self.set_descriptor_table_size(n_descriptors = nil); end
  def self.set_effective_user(username); end
  def self.set_heartbeat_interval(arg0); end
  def self.set_max_timer_count(arg0); end
  def self.set_max_timers(ct); end
  def self.set_notify_readable(arg0, arg1); end
  def self.set_notify_writable(arg0, arg1); end
  def self.set_pending_connect_timeout(arg0, arg1); end
  def self.set_quantum(mills); end
  def self.set_rlimit_nofile(arg0); end
  def self.set_simultaneous_accept_count(arg0); end
  def self.set_sock_opt(arg0, arg1, arg2, arg3); end
  def self.set_timer_quantum(arg0); end
  def self.set_tls_parms(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9); end
  def self.setuid_string(arg0); end
  def self.signal_loopbreak; end
  def self.spawn(&block); end
  def self.spawn_threadpool; end
  def self.ssl?; end
  def self.start_proxy(arg0, arg1, arg2, arg3); end
  def self.start_server(server, port = nil, handler = nil, *args, &block); end
  def self.start_tcp_server(arg0, arg1); end
  def self.start_tls(arg0); end
  def self.start_unix_domain_server(filename, *args, &block); end
  def self.start_unix_server(arg0); end
  def self.stop; end
  def self.stop_event_loop; end
  def self.stop_proxy(arg0); end
  def self.stop_server(signature); end
  def self.stop_tcp_server(arg0); end
  def self.stopping?; end
  def self.system(cmd, *args, &cb); end
  def self.threadpool; end
  def self.threadpool_size; end
  def self.threadpool_size=(arg0); end
  def self.tick_loop(*a, &b); end
  def self.unwatch_filename(arg0); end
  def self.unwatch_pid(arg0); end
  def self.watch(io, handler = nil, *args, &blk); end
  def self.watch_file(filename, handler = nil, *args); end
  def self.watch_filename(arg0); end
  def self.watch_pid(arg0); end
  def self.watch_process(pid, handler = nil, *args); end
  def self.yield(&block); end
  def self.yield_and_notify(&block); end
  def send_data(arg0, arg1, arg2); end
  def send_datagram(arg0, arg1, arg2, arg3, arg4); end
  def send_file_data(arg0, arg1); end
  def set_comm_inactivity_timeout(arg0, arg1); end
  def set_heartbeat_interval(arg0); end
  def set_max_timer_count(arg0); end
  def set_notify_readable(arg0, arg1); end
  def set_notify_writable(arg0, arg1); end
  def set_pending_connect_timeout(arg0, arg1); end
  def set_rlimit_nofile(arg0); end
  def set_simultaneous_accept_count(arg0); end
  def set_sock_opt(arg0, arg1, arg2, arg3); end
  def set_timer_quantum(arg0); end
  def set_tls_parms(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9); end
  def setuid_string(arg0); end
  def signal_loopbreak; end
  def ssl?; end
  def start_proxy(arg0, arg1, arg2, arg3); end
  def start_tcp_server(arg0, arg1); end
  def start_tls(arg0); end
  def start_unix_server(arg0); end
  def stop; end
  def stop_proxy(arg0); end
  def stop_tcp_server(arg0); end
  def stopping?; end
  def unwatch_filename(arg0); end
  def unwatch_pid(arg0); end
  def watch_filename(arg0); end
  def watch_pid(arg0); end
end
class EventMachine::Connection
  def associate_callback_target(arg0); end
  def close_connection(after_writing = nil); end
  def close_connection_after_writing; end
  def comm_inactivity_timeout; end
  def comm_inactivity_timeout=(value); end
  def connection_completed; end
  def detach; end
  def error?; end
  def get_cipher_bits; end
  def get_cipher_name; end
  def get_cipher_protocol; end
  def get_idle_time; end
  def get_outbound_data_size; end
  def get_peer_cert; end
  def get_peername; end
  def get_pid; end
  def get_proxied_bytes; end
  def get_sni_hostname; end
  def get_sock_opt(level, option); end
  def get_sockname; end
  def get_status; end
  def initialize(*args); end
  def notify_readable=(mode); end
  def notify_readable?; end
  def notify_writable=(mode); end
  def notify_writable?; end
  def original_method(arg0); end
  def pause; end
  def paused?; end
  def pending_connect_timeout; end
  def pending_connect_timeout=(value); end
  def post_init; end
  def proxy_completed; end
  def proxy_incoming_to(conn, bufsize = nil); end
  def proxy_target_unbound; end
  def receive_data(data); end
  def reconnect(server, port); end
  def resume; end
  def self.new(sig, *args); end
  def send_data(data); end
  def send_datagram(data, recipient_address, recipient_port); end
  def send_file_data(filename); end
  def set_comm_inactivity_timeout(value); end
  def set_pending_connect_timeout(value); end
  def set_sock_opt(level, optname, optval); end
  def signature; end
  def signature=(arg0); end
  def ssl_handshake_completed; end
  def ssl_verify_peer(cert); end
  def start_tls(args = nil); end
  def stop_proxying; end
  def stream_file_data(filename, args = nil); end
  def unbind; end
end
class EventMachine::Pool
  def add(resource); end
  def completion(deferrable, resource); end
  def contents; end
  def failure(resource); end
  def initialize; end
  def num_waiting; end
  def on_error(*a, &b); end
  def perform(*a, &b); end
  def process(work, resource); end
  def remove(resource); end
  def removed?(resource); end
  def requeue(resource); end
  def reschedule(*a, &b); end
end
module EventMachine::Deferrable
  def callback(&block); end
  def cancel_callback(block); end
  def cancel_errback(block); end
  def cancel_timeout; end
  def errback(&block); end
  def fail(*args); end
  def self.future(arg, cb = nil, eb = nil, &blk); end
  def set_deferred_failure(*args); end
  def set_deferred_status(status, *args); end
  def set_deferred_success(*args); end
  def succeed(*args); end
  def timeout(seconds, *args); end
end
class EventMachine::DefaultDeferrable
  include EventMachine::Deferrable
end
class EventMachine::FileStreamer
  def ensure_mapping_extension_is_present; end
  def initialize(connection, filename, args = nil); end
  def stream_one_chunk; end
  def stream_with_mapping(filename); end
  def stream_without_mapping(filename); end
  include EventMachine::Deferrable
end
class EventMachine::SpawnedProcess
  def notify(*x); end
  def resume(*x); end
  def run(*x); end
  def set_receiver(blk); end
end
class EventMachine::YieldBlockFromSpawnedProcess
  def initialize(block, notify); end
  def pull_out_yield_block; end
end
class EventMachine::DeferrableChildProcess < EventMachine::Connection
  def initialize; end
  def receive_data(data); end
  def self.open(cmd); end
  def unbind; end
  include EventMachine::Deferrable
end
class EventMachine::SystemCmd < EventMachine::Connection
  def initialize(cb); end
  def receive_data(data); end
  def unbind; end
end
class EventMachine::Iterator
  def concurrency; end
  def concurrency=(val); end
  def each(foreach = nil, after = nil, &blk); end
  def initialize(list, concurrency = nil); end
  def inject(obj, foreach, after); end
  def map(foreach, after); end
  def next_item; end
  def spawn_workers; end
end
class BufferedTokenizer
end
class EventMachine::Timer
  def cancel; end
  def initialize(interval, callback = nil, &block); end
end
class EventMachine::PeriodicTimer
  def cancel; end
  def fire; end
  def initialize(interval, callback = nil, &block); end
  def interval; end
  def interval=(arg0); end
  def schedule; end
end
module EventMachine::Protocols
end
class EventMachine::FileNotFoundException < Exception
end
class EventMachine::Queue
  def <<(*items); end
  def empty?; end
  def initialize; end
  def num_waiting; end
  def pop(*a, &b); end
  def push(*items); end
  def size; end
end
class EventMachine::Channel
  def <<(*items); end
  def gen_id; end
  def initialize; end
  def num_subscribers; end
  def pop(*a, &b); end
  def push(*items); end
  def subscribe(*a, &b); end
  def unsubscribe(name); end
end
class EventMachine::FileWatch < EventMachine::Connection
  def file_deleted; end
  def file_modified; end
  def file_moved; end
  def path; end
  def receive_data(data); end
  def stop_watching; end
end
class EventMachine::ProcessWatch < EventMachine::Connection
  def pid; end
  def process_exited; end
  def process_forked; end
  def receive_data(data); end
  def stop_watching; end
end
class EventMachine::TickLoop
  def initialize(*a, &b); end
  def on_stop(*a, &b); end
  def schedule; end
  def start; end
  def stop; end
  def stopped?; end
end
module EventMachine::DNS
end
class EventMachine::DNS::Resolver
  def self.hosts; end
  def self.nameserver; end
  def self.nameservers; end
  def self.nameservers=(ns); end
  def self.resolve(hostname); end
  def self.socket; end
  def self.windows?; end
end
class EventMachine::DNS::RequestIdAlreadyUsed < RuntimeError
end
class EventMachine::DNS::Socket < EventMachine::Connection
  def deregister_request(id, req); end
  def initialize; end
  def nameserver; end
  def nameserver=(ns); end
  def post_init; end
  def receive_data(data); end
  def register_request(id, req); end
  def self.open; end
  def send_packet(pkt); end
  def start_timer; end
  def stop_timer; end
  def tick; end
  def unbind; end
end
class EventMachine::DNS::Request
  def id; end
  def initialize(socket, hostname); end
  def max_tries; end
  def max_tries=(arg0); end
  def packet; end
  def receive_answer(msg); end
  def retry_interval; end
  def retry_interval=(arg0); end
  def send; end
  def tick; end
  include EventMachine::Deferrable
end
class EventMachine::Completion
  def callback(*a, &b); end
  def cancel_callback(*a, &b); end
  def cancel_errback(*a, &b); end
  def cancel_timeout; end
  def change_state(state, *args); end
  def clear_dead_callbacks; end
  def completed?; end
  def completion(*a, &b); end
  def completion_states; end
  def errback(*a, &b); end
  def execute_callbacks; end
  def execute_state_callbacks(state); end
  def fail(*args); end
  def initialize; end
  def set_deferred_failure(*args); end
  def set_deferred_status(state, *args); end
  def set_deferred_success(*args); end
  def state; end
  def stateback(state, *a, &b); end
  def succeed(*args); end
  def timeout(time, *args); end
  def value; end
  include EventMachine::Deferrable
end
class EventMachine::ThreadedResource
  def dispatch; end
  def initialize; end
  def shutdown; end
end
