# frozen_string_literal: true

require "spec_helper"

describe AuthoritiesController do
  before do
    request.env["HTTPS"] = "on"
  end

  describe "#index" do
    it { expect(get(:index)).to be_successful }
  end
end
