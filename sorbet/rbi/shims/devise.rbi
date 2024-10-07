# typed: strict

module Devise
  class RegistrationsController < DeviseController
    def create; end
  end

  class SessionsController < DeviseController
    def new; end
    def auth_options; end
  end

  class ConfirmationsController < DeviseController
  end
end

class DeviseController < ApplicationController
end
