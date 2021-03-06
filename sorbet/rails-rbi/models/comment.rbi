# This is an autogenerated file for dynamic methods in Comment
# Please rerun bundle exec rake rails_rbi:models[Comment] to regenerate.

# typed: strong
module Comment::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module Comment::GeneratedAttributeMethods
  sig { returns(T.nilable(String)) }
  def address; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def address=(value); end

  sig { returns(T::Boolean) }
  def address?; end

  sig { returns(Integer) }
  def application_id; end

  sig { params(value: T.any(Numeric, ActiveSupport::Duration)).void }
  def application_id=(value); end

  sig { returns(T::Boolean) }
  def application_id?; end

  sig { returns(T.nilable(String)) }
  def confirm_id; end

  sig { params(value: T.nilable(T.any(String, Symbol))).void }
  def confirm_id=(value); end

  sig { returns(T::Boolean) }
  def confirm_id?; end

  sig { returns(T.nilable(T::Boolean)) }
  def confirmed; end

  sig { params(value: T.nilable(T::Boolean)).void }
  def confirmed=(value); end

  sig { returns(T::Boolean) }
  def confirmed?; end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def confirmed_at; end

  sig { params(value: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone))).void }
  def confirmed_at=(value); end

  sig { returns(T::Boolean) }
  def confirmed_at?; end

  sig { returns(T.nilable(Integer)) }
  def councillor_id; end

  sig { params(value: T.nilable(T.any(Numeric, ActiveSupport::Duration))).void }
  def councillor_id=(value); end

  sig { returns(T::Boolean) }
  def councillor_id?; end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def created_at; end

  sig { params(value: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone))).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(String) }
  def email; end

  sig { params(value: T.any(String, Symbol)).void }
  def email=(value); end

  sig { returns(T::Boolean) }
  def email?; end

  sig { returns(T::Boolean) }
  def hidden; end

  sig { params(value: T::Boolean).void }
  def hidden=(value); end

  sig { returns(T::Boolean) }
  def hidden?; end

  sig { returns(Integer) }
  def id; end

  sig { params(value: T.any(Numeric, ActiveSupport::Duration)).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(String) }
  def name; end

  sig { params(value: T.any(String, Symbol)).void }
  def name=(value); end

  sig { returns(T::Boolean) }
  def name?; end

  sig { returns(String) }
  def text; end

  sig { params(value: T.any(String, Symbol)).void }
  def text=(value); end

  sig { returns(T::Boolean) }
  def text?; end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def updated_at; end

  sig { params(value: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone))).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end

  sig { returns(T.nilable(Integer)) }
  def writeit_message_id; end

  sig { params(value: T.nilable(T.any(Numeric, ActiveSupport::Duration))).void }
  def writeit_message_id=(value); end

  sig { returns(T::Boolean) }
  def writeit_message_id?; end
end

module Comment::GeneratedAssociationMethods
  sig { returns(::Application) }
  def application; end

  sig { params(value: ::Application).void }
  def application=(value); end

  sig { returns(T.nilable(::Councillor)) }
  def councillor; end

  sig { params(value: T.nilable(::Councillor)).void }
  def councillor=(value); end

  sig { returns(::Reply::ActiveRecord_Associations_CollectionProxy) }
  def replies; end

  sig { returns(T::Array[Integer]) }
  def reply_ids; end

  sig { params(value: T::Enumerable[::Reply]).void }
  def replies=(value); end

  sig { returns(::Report::ActiveRecord_Associations_CollectionProxy) }
  def reports; end

  sig { returns(T::Array[Integer]) }
  def report_ids; end

  sig { params(value: T::Enumerable[::Report]).void }
  def reports=(value); end
end

module Comment::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[Comment]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[Comment]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[Comment]) }
  def find_n(*args); end

  sig { params(id: Integer).returns(T.nilable(Comment)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(Comment) }
  def find_by_id!(id); end
end

class Comment < ApplicationRecord
  include Comment::GeneratedAttributeMethods
  include Comment::GeneratedAssociationMethods
  extend Comment::CustomFinderMethods
  extend Comment::QueryMethodsReturningRelation
  RelationType = T.type_alias { T.any(Comment::ActiveRecord_Relation, Comment::ActiveRecord_Associations_CollectionProxy, Comment::ActiveRecord_AssociationRelation) }

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def self.confirmed(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def self.in_past_week(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def self.to_councillor(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def self.visible(*args); end
end

class Comment::ActiveRecord_Relation < ActiveRecord::Relation
  include Comment::ActiveRelation_WhereNot
  include Comment::CustomFinderMethods
  include Comment::QueryMethodsReturningRelation
  Elem = type_member(fixed: Comment)

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def confirmed(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def in_past_week(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def to_councillor(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def visible(*args); end
end

class Comment::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include Comment::ActiveRelation_WhereNot
  include Comment::CustomFinderMethods
  include Comment::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Comment)

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def confirmed(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def in_past_week(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def to_councillor(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def visible(*args); end
end

class Comment::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include Comment::CustomFinderMethods
  include Comment::QueryMethodsReturningAssociationRelation
  Elem = type_member(fixed: Comment)

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def confirmed(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def in_past_week(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def to_councillor(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def visible(*args); end

  sig { params(records: T.any(Comment, T::Array[Comment])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(Comment, T::Array[Comment])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(Comment, T::Array[Comment])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(Comment, T::Array[Comment])).returns(T.self_type) }
  def concat(*records); end
end

module Comment::QueryMethodsReturningRelation
  sig { returns(Comment::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Comment::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_Relation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Comment::ActiveRecord_Relation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Comment::ActiveRecord_Relation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end

module Comment::QueryMethodsReturningAssociationRelation
  sig { returns(Comment::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(Comment::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def select(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def order(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def reorder(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def group(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def limit(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def offset(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def joins(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def left_joins(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def left_outer_joins(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def where(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def rewhere(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def preload(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def eager_load(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def includes(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def from(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def lock(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def readonly(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def or(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def having(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def create_with(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def distinct(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def references(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def none(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def unscope(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def merge(*args); end

  sig { params(args: T.untyped).returns(Comment::ActiveRecord_AssociationRelation) }
  def except(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(Comment::ActiveRecord_AssociationRelation) }
  def extending(*args, &block); end

  sig do
    params(
      of: T.nilable(Integer),
      start: T.nilable(Integer),
      finish: T.nilable(Integer),
      load: T.nilable(T::Boolean),
      error_on_ignore: T.nilable(T::Boolean),
      block: T.nilable(T.proc.params(e: Comment::ActiveRecord_AssociationRelation).void)
    ).returns(ActiveRecord::Batches::BatchEnumerator)
  end
  def in_batches(of: 1000, start: nil, finish: nil, load: false, error_on_ignore: nil, &block); end
end
