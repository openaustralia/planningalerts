# This is an autogenerated file for dynamic methods in ApplicationRedirect
# Please rerun bundle exec rake rails_rbi:models[ApplicationRedirect] to regenerate.

# typed: strong
module ApplicationRedirect::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module ApplicationRedirect::GeneratedAttributeMethods
  sig { returns(Integer) }
  def application_id; end

  sig { params(value: T.any(Numeric, ActiveSupport::Duration)).void }
  def application_id=(value); end

  sig { returns(T::Boolean) }
  def application_id?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(Integer) }
  def id; end

  sig { params(value: T.any(Numeric, ActiveSupport::Duration)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(Integer) }
  def redirect_application_id; end

  sig { params(value: T.any(Numeric, ActiveSupport::Duration)).void }
  def redirect_application_id=(value); end

  sig { returns(T::Boolean) }
  def redirect_application_id?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end
end

module ApplicationRedirect::GeneratedAssociationMethods
  sig { returns(::Application) }
  def redirect_application; end

  sig { params(value: ::Application).void }
  def redirect_application=(value); end
end

module ApplicationRedirect::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[ApplicationRedirect]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[ApplicationRedirect]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[ApplicationRedirect]) }
  def find_n(*args); end

  sig { params(id: Integer).returns(T.nilable(ApplicationRedirect)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(ApplicationRedirect) }
  def find_by_id!(id); end
end

class ApplicationRedirect < ApplicationRecord
  include ApplicationRedirect::GeneratedAttributeMethods
  include ApplicationRedirect::GeneratedAssociationMethods
  extend ApplicationRedirect::CustomFinderMethods
  extend ApplicationRedirect::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(ApplicationRedirect::ActiveRecord_Relation, ApplicationRedirect::ActiveRecord_Associations_CollectionProxy, ApplicationRedirect::ActiveRecord_AssociationRelation) }
end

module ApplicationRedirect::QueryMethodsReturningRelation
  sig { returns(ApplicationRedirect::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: ApplicationRedirect::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module ApplicationRedirect::QueryMethodsReturningAssociationRelation
  sig { returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(ApplicationRedirect::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ApplicationRedirect::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: ApplicationRedirect::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

class ApplicationRedirect::ActiveRecord_Relation < ActiveRecord::Relation
  include ApplicationRedirect::ActiveRelation_WhereNot
  include ApplicationRedirect::CustomFinderMethods
  include ApplicationRedirect::QueryMethodsReturningRelation
  Elem = type_member(fixed: ApplicationRedirect)
end

class ApplicationRedirect::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include ApplicationRedirect::ActiveRelation_WhereNot
  include ApplicationRedirect::CustomFinderMethods
  include ApplicationRedirect::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: ApplicationRedirect)
end

class ApplicationRedirect::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include ApplicationRedirect::CustomFinderMethods
  include ApplicationRedirect::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: ApplicationRedirect)

  sig { params(records: T.any(ApplicationRedirect, T::Array[ApplicationRedirect])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(ApplicationRedirect, T::Array[ApplicationRedirect])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(ApplicationRedirect, T::Array[ApplicationRedirect])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(ApplicationRedirect, T::Array[ApplicationRedirect])).returns(T.self_type) }
  def concat(*records); end
end
