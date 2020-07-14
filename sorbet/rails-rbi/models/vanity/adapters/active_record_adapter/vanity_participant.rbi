# This is an autogenerated file for dynamic methods in Vanity::Adapters::ActiveRecordAdapter::VanityParticipant
# Please rerun bundle exec rake rails_rbi:models[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant] to regenerate.

# typed: strong
module Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::GeneratedAttributeMethods
  sig { returns(T.nilable(Integer)) }
  def converted; end

  sig { params(value: T.nilable(T.any(Numeric, ActiveSupport::Duration))).void }
  def converted=(value); end

  sig { returns(T::Boolean) }
  def converted?; end

  sig { returns(T.nilable(String)) }
  def experiment_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def experiment_id=(value); end

  sig { returns(T::Boolean) }
  def experiment_id?; end

  sig { returns(Integer) }
  def id; end

  sig { params(value: T.any(Numeric, ActiveSupport::Duration)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(T.nilable(String)) }
  def identity; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def identity=(value); end

  sig { returns(T::Boolean) }
  def identity?; end

  sig { returns(T.nilable(Integer)) }
  def seen; end

  sig { params(value: T.nilable(T.any(Numeric, ActiveSupport::Duration))).void }
  def seen=(value); end

  sig { returns(T::Boolean) }
  def seen?; end

  sig { returns(T.nilable(Integer)) }
  def shown; end

  sig { params(value: T.nilable(T.any(Numeric, ActiveSupport::Duration))).void }
  def shown=(value); end

  sig { returns(T::Boolean) }
  def shown?; end
end

module Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant]) }
  def find_n(*args); end

  sig { params(id: Integer).returns(T.nilable(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant) }
  def find_by_id!(id); end
end

class Vanity::Adapters::ActiveRecordAdapter::VanityParticipant < Vanity::Adapters::ActiveRecordAdapter::VanityRecord
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::GeneratedAttributeMethods
  extend Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::CustomFinderMethods
  extend Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation, Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Associations_CollectionProxy, Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
end

module Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::QueryMethodsReturningRelation
  sig { returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::QueryMethodsReturningAssociationRelation
  sig { returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Relation < ActiveRecord::Relation
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRelation_WhereNot
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::CustomFinderMethods
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::QueryMethodsReturningRelation
  Elem = type_member(fixed: Vanity::Adapters::ActiveRecordAdapter::VanityParticipant)
end

class Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRelation_WhereNot
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::CustomFinderMethods
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Vanity::Adapters::ActiveRecordAdapter::VanityParticipant)
end

class Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::CustomFinderMethods
  include Vanity::Adapters::ActiveRecordAdapter::VanityParticipant::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Vanity::Adapters::ActiveRecordAdapter::VanityParticipant)

  sig { params(records: T.any(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant, T::Array[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant, T::Array[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant, T::Array[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(Vanity::Adapters::ActiveRecordAdapter::VanityParticipant, T::Array[Vanity::Adapters::ActiveRecordAdapter::VanityParticipant])).returns(T.self_type) }
  def concat(*records); end
end