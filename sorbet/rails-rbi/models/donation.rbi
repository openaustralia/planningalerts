# This is an autogenerated file for dynamic methods in Donation
# Please rerun bundle exec rake rails_rbi:models[Donation] to regenerate.

# typed: strong
module Donation::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module Donation::GeneratedAttributeMethods
  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(String) }
  def email; end

  sig { params(value: T.any(String, Symbol)).void }
  def email=(value); end

  sig { returns(T::Boolean) }
  def email?; end

  sig { returns(Integer) }
  def id; end

  sig { params(value: T.any(Numeric, ActiveSupport::Duration)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(T.nilable(String)) }
  def stripe_customer_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def stripe_customer_id=(value); end

  sig { returns(T::Boolean) }
  def stripe_customer_id?; end

  sig { returns(T.nilable(String)) }
  def stripe_plan_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def stripe_plan_id=(value); end

  sig { returns(T::Boolean) }
  def stripe_plan_id?; end

  sig { returns(T.nilable(String)) }
  def stripe_subscription_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def stripe_subscription_id=(value); end

  sig { returns(T::Boolean) }
  def stripe_subscription_id?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end
end

module Donation::GeneratedAssociationMethods
  sig { returns(::Alert::ActiveRecord_Associations_CollectionProxy) }
  def alerts; end

  sig { returns(T::Array[Integer]) }
  def alert_ids; end

  sig { params(value: T::Enumerable[::Alert]).void }
  def alerts=(value); end
end

module Donation::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[Donation]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[Donation]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[Donation]) }
  def find_n(*args); end

  sig { params(id: Integer).returns(T.nilable(Donation)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(Donation) }
  def find_by_id!(id); end
end

class Donation < ApplicationRecord
  include Donation::GeneratedAttributeMethods
  include Donation::GeneratedAssociationMethods
  extend Donation::CustomFinderMethods
  extend Donation::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(Donation::ActiveRecord_Relation, Donation::ActiveRecord_Associations_CollectionProxy, Donation::ActiveRecord_AssociationRelation) }
end

module Donation::QueryMethodsReturningRelation
  sig { returns(Donation::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Donation::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Donation::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Donation::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module Donation::QueryMethodsReturningAssociationRelation
  sig { returns(Donation::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Donation::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Donation::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Donation::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Donation::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class Donation::ActiveRecord_Relation < ActiveRecord::Relation
  include Donation::ActiveRelation_WhereNot
  include Donation::CustomFinderMethods
  include Donation::QueryMethodsReturningRelation
  Elem = type_member(fixed: Donation)
end

class Donation::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include Donation::ActiveRelation_WhereNot
  include Donation::CustomFinderMethods
  include Donation::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Donation)
end

class Donation::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include Donation::CustomFinderMethods
  include Donation::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Donation)

  sig { params(records: T.any(Donation, T::Array[Donation])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(Donation, T::Array[Donation])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(Donation, T::Array[Donation])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(Donation, T::Array[Donation])).returns(T.self_type) }
  def concat(*records); end
end
