# typed: strict

# TODO: This should be removed when collection_proxy.rbi is removed

# These are truly horrible hacks as we're defining this on all the generic types

class ActiveRecord::Associations::CollectionProxy < ::ActiveRecord::Relation
  def visible; end
end
