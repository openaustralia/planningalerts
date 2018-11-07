# frozen_string_literal: true

require "spec_helper"

describe AuthoritiesController do
  before :each do
    request.env["HTTPS"] = "on"
  end

  describe "#index" do
    it { expect(get(:index)).to be_success }
  end
end
