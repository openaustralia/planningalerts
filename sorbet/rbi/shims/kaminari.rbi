# typed: strict

module ActiveRecord
  class Relation
    sig { params(page: T.untyped).returns(ActiveRecord::Relation) }
    def page(page); end

    sig { params(number: Integer).returns(ActiveRecord::Relation) }
    def per(number); end
  end
end
