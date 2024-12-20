# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `growl` gem.
# Please instead update this file by running `bin/tapioca gem growl`.


# source://growl//lib/growl/version.rb#2
module Growl
  private

  # Display a growl notification +message+, with +options+
  # documented below. Alternatively a +block+ may be passed
  # which is then instance evaluated or yielded to the block.
  #
  # This method is simply returns nil when growlnotify
  # is not installed, as growl notifications should never
  # be the only means of communication between your application
  # and your user.
  #
  # === Examples
  #
  #   Growl.notify 'Hello'
  #   Growl.notify 'Hello', :title => 'TJ Says:', :sticky => true
  #   Growl.notify { |n| n.message = 'Hello'; n.sticky! }
  #   Growl.notify { self.message = 'Hello'; sticky! }
  #
  # source://growl//lib/growl/growl.rb#30
  def notify(message = T.unsafe(nil), options = T.unsafe(nil), &block); end

  # source://growl//lib/growl/growl.rb#43
  def notify_error(message, *args); end

  # source://growl//lib/growl/growl.rb#43
  def notify_info(message, *args); end

  # source://growl//lib/growl/growl.rb#43
  def notify_ok(message, *args); end

  # source://growl//lib/growl/growl.rb#43
  def notify_warning(message, *args); end

  class << self
    # Execute +args+ against the binary.
    #
    # source://growl//lib/growl/growl.rb#54
    def exec(*args); end

    # Check if the binary is installed and accessable.
    #
    # @return [Boolean]
    #
    # source://growl//lib/growl/growl.rb#68
    def installed?; end

    # Return an instance of Growl::Base or nil when not installed.
    #
    # source://growl//lib/growl/growl.rb#75
    def new(*args, &block); end

    # Normalize the icon option in +options+. This performs
    # the following operations in order to allow for the :icon
    # key to work with a variety of values:
    #
    # * path to an icon sets :iconpath
    # * path to an image sets :image
    # * capitalized word sets :appIcon
    # * filename uses extname as :icon
    # * otherwise treated as :icon
    #
    # source://growl//lib/growl/growl.rb#91
    def normalize_icon!(options = T.unsafe(nil)); end

    # Display a growl notification +message+, with +options+
    # documented below. Alternatively a +block+ may be passed
    # which is then instance evaluated or yielded to the block.
    #
    # This method is simply returns nil when growlnotify
    # is not installed, as growl notifications should never
    # be the only means of communication between your application
    # and your user.
    #
    # === Examples
    #
    #   Growl.notify 'Hello'
    #   Growl.notify 'Hello', :title => 'TJ Says:', :sticky => true
    #   Growl.notify { |n| n.message = 'Hello'; n.sticky! }
    #   Growl.notify { self.message = 'Hello'; sticky! }
    #
    # source://growl//lib/growl/growl.rb#30
    def notify(message = T.unsafe(nil), options = T.unsafe(nil), &block); end

    # source://growl//lib/growl/growl.rb#43
    def notify_error(message, *args); end

    # source://growl//lib/growl/growl.rb#43
    def notify_info(message, *args); end

    # source://growl//lib/growl/growl.rb#43
    def notify_ok(message, *args); end

    # source://growl//lib/growl/growl.rb#43
    def notify_warning(message, *args); end

    # Return the version triple of the binary.
    #
    # source://growl//lib/growl/growl.rb#61
    def version; end
  end
end

# source://growl//lib/growl/growl.rb#4
Growl::BIN = T.let(T.unsafe(nil), String)

# --
# Growl base
# ++
#
# source://growl//lib/growl/growl.rb#115
class Growl::Base
  # Initialize with optional +block+, which is then
  # instance evaled or yielded depending on the blocks arity.
  #
  # @return [Base] a new instance of Base
  #
  # source://growl//lib/growl/growl.rb#122
  def initialize(options = T.unsafe(nil), &block); end

  # source://growl//lib/growl/growl.rb#167
  def appIcon; end

  # source://growl//lib/growl/growl.rb#169
  def appIcon!; end

  # source://growl//lib/growl/growl.rb#167
  def appIcon=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def appIcon?; end

  # Returns the value of attribute args.
  #
  # source://growl//lib/growl/growl.rb#116
  def args; end

  # source://growl//lib/growl/growl.rb#167
  def auth; end

  # source://growl//lib/growl/growl.rb#169
  def auth!; end

  # source://growl//lib/growl/growl.rb#167
  def auth=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def auth?; end

  # source://growl//lib/growl/growl.rb#167
  def crypt; end

  # source://growl//lib/growl/growl.rb#169
  def crypt!; end

  # source://growl//lib/growl/growl.rb#167
  def crypt=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def crypt?; end

  # source://growl//lib/growl/growl.rb#167
  def host; end

  # source://growl//lib/growl/growl.rb#169
  def host!; end

  # source://growl//lib/growl/growl.rb#167
  def host=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def host?; end

  # source://growl//lib/growl/growl.rb#167
  def icon; end

  # source://growl//lib/growl/growl.rb#169
  def icon!; end

  # source://growl//lib/growl/growl.rb#167
  def icon=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def icon?; end

  # source://growl//lib/growl/growl.rb#167
  def iconpath; end

  # source://growl//lib/growl/growl.rb#169
  def iconpath!; end

  # source://growl//lib/growl/growl.rb#167
  def iconpath=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def iconpath?; end

  # source://growl//lib/growl/growl.rb#167
  def identifier; end

  # source://growl//lib/growl/growl.rb#169
  def identifier!; end

  # source://growl//lib/growl/growl.rb#167
  def identifier=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def identifier?; end

  # source://growl//lib/growl/growl.rb#167
  def image; end

  # source://growl//lib/growl/growl.rb#169
  def image!; end

  # source://growl//lib/growl/growl.rb#167
  def image=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def image?; end

  # source://growl//lib/growl/growl.rb#167
  def message; end

  # source://growl//lib/growl/growl.rb#169
  def message!; end

  # source://growl//lib/growl/growl.rb#167
  def message=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def message?; end

  # source://growl//lib/growl/growl.rb#167
  def name; end

  # source://growl//lib/growl/growl.rb#169
  def name!; end

  # source://growl//lib/growl/growl.rb#167
  def name=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def name?; end

  # source://growl//lib/growl/growl.rb#167
  def password; end

  # source://growl//lib/growl/growl.rb#169
  def password!; end

  # source://growl//lib/growl/growl.rb#167
  def password=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def password?; end

  # source://growl//lib/growl/growl.rb#167
  def port; end

  # source://growl//lib/growl/growl.rb#169
  def port!; end

  # source://growl//lib/growl/growl.rb#167
  def port=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def port?; end

  # source://growl//lib/growl/growl.rb#167
  def priority; end

  # source://growl//lib/growl/growl.rb#169
  def priority!; end

  # source://growl//lib/growl/growl.rb#167
  def priority=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def priority?; end

  # Run the notification, only --message is required.
  #
  # @raise [Error]
  #
  # source://growl//lib/growl/growl.rb#140
  def run; end

  # source://growl//lib/growl/growl.rb#167
  def sticky; end

  # source://growl//lib/growl/growl.rb#169
  def sticky!; end

  # source://growl//lib/growl/growl.rb#167
  def sticky=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def sticky?; end

  # source://growl//lib/growl/growl.rb#167
  def title; end

  # source://growl//lib/growl/growl.rb#169
  def title!; end

  # source://growl//lib/growl/growl.rb#167
  def title=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def title?; end

  # source://growl//lib/growl/growl.rb#167
  def udp; end

  # source://growl//lib/growl/growl.rb#169
  def udp!; end

  # source://growl//lib/growl/growl.rb#167
  def udp=(_arg0); end

  # source://growl//lib/growl/growl.rb#168
  def udp?; end

  class << self
    # Define a switch +name+.
    #
    # === examples
    #
    #  switch :sticky
    #
    #  @growl.sticky!         # => true
    #  @growl.sticky?         # => true
    #  @growl.sticky = false  # => false
    #  @growl.sticky?         # => false
    #
    # source://growl//lib/growl/growl.rb#164
    def switch(name); end

    # Return array of available switch symbols.
    #
    # source://growl//lib/growl/growl.rb#175
    def switches; end
  end
end

# --
# Exceptions
# ++
#
# source://growl//lib/growl/growl.rb#10
class Growl::Error < ::StandardError; end

# source://growl//lib/growl/version.rb#3
Growl::VERSION = T.let(T.unsafe(nil), String)
