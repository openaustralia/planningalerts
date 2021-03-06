# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/naught/all/naught.rbi
#
# naught-1.1.0

module Naught
  def self.build(&customization_block); end
end
class Naught::BasicObject < BasicObject
end
module Naught::Conversions
  def Actual(object = nil); end
  def Just(object = nil); end
  def Maybe(object = nil); end
  def Null(object = nil); end
  def self.included(null_class); end
end
class Naught::NullClassBuilder
  def apply_operations(operations, module_or_class); end
  def base_class; end
  def base_class=(arg0); end
  def black_hole; end
  def class_operations; end
  def command_name_for_method(method_name); end
  def customization_module; end
  def customize(&customization_block); end
  def defer(options = nil, &deferred_operation); end
  def define_basic_class_methods; end
  def define_basic_instance_methods; end
  def define_basic_methods; end
  def generate_class; end
  def initialize; end
  def inspect_proc; end
  def inspect_proc=(arg0); end
  def interface_defined; end
  def interface_defined=(arg0); end
  def interface_defined?; end
  def method_missing(method_name, *args, &block); end
  def null_equivalents; end
  def operations; end
  def respond_to_any_message; end
  def respond_to_definition(method_name, include_private, respond_to_method_name); end
  def respond_to_missing?(method_name, include_private = nil); end
  def stub_method(subject, name); end
  def stub_method_returning_nil(subject, name); end
  def stub_method_returning_self(subject, name); end
  def super_duper(method_name, *args); end
end
module Naught::NullClassBuilder::Commands
end
class Naught::NullClassBuilder::Command
  def builder; end
  def call; end
  def defer(options = nil, &block); end
  def initialize(builder); end
end
class Naught::NullClassBuilder::Commands::DefineExplicitConversions < Naught::NullClassBuilder::Command
  def call; end
end
class Naught::NullClassBuilder::Commands::DefineImplicitConversions < Naught::NullClassBuilder::Command
  def call; end
end
class Naught::NullClassBuilder::Commands::Pebble < Naught::NullClassBuilder::Command
  def call; end
  def initialize(builder, output = nil); end
end
class Naught::NullClassBuilder::Commands::PredicatesReturn < Naught::NullClassBuilder::Command
  def call; end
  def define_method_missing(subject); end
  def define_predicate_methods(subject); end
  def initialize(builder, return_value); end
end
class Naught::NullClassBuilder::Commands::Singleton < Naught::NullClassBuilder::Command
  def call; end
end
class Naught::NullClassBuilder::Commands::Traceable < Naught::NullClassBuilder::Command
  def call; end
end
class Naught::NullClassBuilder::Commands::Mimic < Naught::NullClassBuilder::Command
  def call; end
  def class_to_mimic; end
  def include_super; end
  def initialize(builder, class_to_mimic_or_options, options = nil); end
  def methods_to_stub; end
  def root_class_of(klass); end
  def singleton_class; end
end
class Naught::NullClassBuilder::Commands::Mimic::NULL_SINGLETON_CLASS
end
class Naught::NullClassBuilder::Commands::Impersonate < Naught::NullClassBuilder::Commands::Mimic
  def initialize(builder, class_to_impersonate, options = nil); end
end
module Naught::NullObjectTag
end
