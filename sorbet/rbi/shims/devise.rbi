# typed: strict

module Devise
  class RegistrationsController < DeviseController
    def create; end
  end

  class SessionsController < DeviseController
  end

  class ConfirmationsController < DeviseController
  end
end

class DeviseController < ApplicationController
end
