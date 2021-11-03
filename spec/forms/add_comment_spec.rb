# frozen_string_literal: true

require "spec_helper"

describe AddComment do
  describe "#save_comment" do
    let(:application) { create(:geocoded_application) }
    let(:add_comment_form) do
      build(:add_comment, application: application,
                          comment_for: nil,
                          text: "Testing testing 1 2 3")
    end

    it "is valid without specificing who it is for" do
      expect(add_comment_form).to be_valid
    end

    it "creates the comment with the correct attributes" do
      expect(add_comment_form.save_comment).to be_an_instance_of(Comment)
      expect(application.comments.first.text).to eq "Testing testing 1 2 3"
    end

    context "and there is no address" do
      before { add_comment_form.address = nil }

      it { expect(add_comment_form).not_to be_valid }
    end

    context "and an address is present" do
      before { add_comment_form.address = "64 Fake st" }

      it { expect(add_comment_form).to be_valid }
    end
  end
end
