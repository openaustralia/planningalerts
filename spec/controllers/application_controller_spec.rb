# frozen_string_literal: true

require "spec_helper"

describe ApplicationController do
  controller do
    def index
      render plain: nil
    end
  end
end
