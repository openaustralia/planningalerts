# typed: strict

module Devise
  class RegistrationsController < DeviseController
    sig { params(blk: T.nilable(T.proc.params(resource: T.untyped).void)).void }
    def new(&blk); end

    sig { params(blk: T.nilable(T.proc.params(resource: T.untyped).void)).void }
    def create(&blk); end

    sig { returns(T.untyped) }
    def resource; end
  end

  class SessionsController < DeviseController
    sig { params(blk: T.nilable(T.proc.void)).void }
    def new(&blk); end

    sig { returns(T.untyped) }
    def auth_options; end
  end

  class ConfirmationsController < DeviseController
  end
end

class DeviseController < ApplicationController
end
