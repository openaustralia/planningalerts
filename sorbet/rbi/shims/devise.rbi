# typed: strict

module Devise
  class RegistrationsController < DeviseController
    sig { params(blk: T.nilable(T.proc.params(resource: T.untyped).void)).void }
    def new(&blk); end

    sig { params(blk: T.nilable(T.proc.params(resource: T.untyped).void)).void }
    def create(&blk); end

    sig { returns(T.untyped) }
    def resource; end

    sig { params(resource: T.untyped).returns(T.untyped) }
    def resource=(resource); end

    sig { returns(T.untyped) }
    def resource_class; end

    sig { returns(T.untyped) }
    def sign_up_params; end
  end

  class SessionsController < DeviseController
    sig { params(blk: T.nilable(T.proc.void)).void }
    def new(&blk); end

    sig { returns(T.untyped) }
    def auth_options; end
  end

  class ConfirmationsController < DeviseController
    sig { returns(T.untyped) }
    def resource; end

    sig { params(resource: T.untyped).returns(T.untyped) }
    def resource=(resource); end

    sig { returns(T.untyped) }
    def resource_class; end
  end

  class PasswordsController < DeviseController
    sig { returns(T.untyped) }
    def resource; end

    sig { params(resource: T.untyped).returns(T.untyped) }
    def resource=(resource); end

    sig { returns(T.untyped) }
    def resource_class; end
  end
end

class DeviseController < ApplicationController
end
