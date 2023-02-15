# typed: true

module Aws
  module Structure; end
  class EmptyStructure; end

  module Errors
    class ServiceError; end
    module DynamicErrors; end
  end

  module Resources
    class Collection; end
  end

  module Deprecations; end
  module ClientStubs; end
end

module Seahorse
  module Client
    class Handler; end
    class Plugin; end
    class Base; end
  end

  module Model
    class Api; end

    module Shapes
      class StructureShape; end
      class StringShape; end
      class ListShape; end
      class BlobShape; end
      class IntegerShape; end
      class BooleanShape; end
      class MapShape; end
      class TimestampShape; end
    end
  end
end
