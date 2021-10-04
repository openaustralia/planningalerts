# typed: true

# This is a workaround from https://github.com/Shopify/tapioca/issues/179
# In theory this should be fixed when this PR is merged:
# https://github.com/Shopify/tapioca/pull/236

class ActiveRecord::Associations::CollectionProxy < ::ActiveRecord::Relation
  extend(T::Generic)

  Elem = type_member

  sig { params(block: T.nilable(T.proc.params(arg: Elem).void)).returns(T::Enumerator[Elem]) }
  def each(&block); end

  sig do
    returns(T.untyped)
  end
  def target; end

  sig { void }
  def load_target; end

  sig { void }
  def reload; end

  sig { void }
  def reset; end

  sig { void }
  def reset_scope; end

  sig { returns(T::Boolean) }
  def loaded?; end

  sig { params(args: T.untyped).returns(Elem) }
  def find(*args); end

  def last(limit = nil); end

  def take(limit = nil); end

  sig do
    params(attributes: ::Hash, block: T.nilable(T.proc.returns(T.untyped))).returns(Elem)
  end
  def build(attributes = {}, &block); end

  sig do
    params(attributes: ::Hash, block: T.nilable(T.proc.returns(T.untyped))).returns(Elem)
  end
  def create(attributes = {}, &block); end

  sig do
    params(attributes: ::Hash, block: T.nilable(T.proc.returns(T.untyped))).returns(Elem)
  end
  def create!(attributes = {}, &block); end

  sig { params(records: T.any(Elem, T::Array[Elem], T::Array[ActiveRecord::Associations::CollectionProxy[Elem]])).void }
  def concat(*records); end

  sig { params(other_array: T.any(T::Array[Elem], T.self_type)).void }
  def replace(other_array); end

  sig { params(dependent: ::Symbol).void }
  def delete_all(dependent = nil); end

  sig { void }
  def destroy_all; end

  sig { params(records: T.any(Elem, T::Array[Elem])).void }
  def delete(*records); end

  sig { params(records: T.any(Elem, T::Array[Elem])).void }
  def destroy(*records); end

  def calculate(operation, column_name); end

  def pluck(*column_names); end

  sig { returns(::Integer) }
  def size; end

  sig { returns(T::Boolean) }
  def empty?; end

  sig { params(record: Elem).returns(T::Boolean) }
  def include?(record); end

  def proxy_association; end

  def scope; end

  sig { params(other: T.any(T.self_type, T::Array[Elem])).returns(T::Boolean) }
  def ==(other); end

  sig { params(records: T.any(Elem, T::Array[Elem], T::Array[ActiveRecord::Associations::CollectionProxy[Elem]])).void }
  def <<(*records); end

  sig { params(args: Elem).void }
  def prepend(*args); end

  sig { void }
  def clear; end

  sig { params(fields: T.any(Symbol, String)).returns(ActiveRecord::Associations::CollectionProxy[Elem]) }
  def select(*fields); end
end
