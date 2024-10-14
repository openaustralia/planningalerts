# typed: strict

module Devise
  class RegistrationsController < DeviseController
    def new; end
    def create; end
    def resource; end
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
