# frozen_string_literal: true

require "spec_helper"

describe ApplicationController do
  controller do
    def index
      render text: nil
    end
  end

  describe "#validate_page_param" do
    it "should try to convert page param to an integer" do
      get :index, params: { page: "2%5B&q" }

      expect(controller.params[:page]).to eq(2)
    end

    it "should default to page nil when no page number param is given" do
      get :index, params: { page: "%5B&q" }

      expect(controller.params[:page]).to eq(nil)
    end
  end
end
