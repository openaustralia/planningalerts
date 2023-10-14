# frozen_string_literal: true

require "spec_helper"

describe Comment do
  context "when new comment for a planning authority" do
    let(:comment_to_authority) { create(:comment) }
    let(:application) { create(:application) }
    let(:user) { create(:user) }

    it "is not valid without an address" do
      comment_to_authority.address = nil

      expect(comment_to_authority).not_to be_valid
    end

    it "is valid with an address" do
      comment_to_authority.address = "64 Fake St"

      expect(comment_to_authority).to be_valid
    end

    it "handles emojis in the comment text" do
      comment_to_authority.text = "🙏🏼"
      expect { comment_to_authority.save! }.not_to raise_error
    end

    context "with unpublished comments" do
      it "is valid to have one comment on an application for a particular user" do
        comment = build(:comment, application:, user:, published: false)
        expect(comment).to be_valid
      end

      it "is not valid to have more than one comment on an application for a particular user" do
        create(:comment, application:, user:, published: false)
        comment = build(:comment, application:, user:, published: false)
        expect(comment).not_to be_valid
      end

      it "is valid to have more than one comment on an application from different users" do
        create(:comment, application:, user: create(:user), published: false)
        comment = build(:comment, application:, user: create(:user), published: false)
        expect(comment).to be_valid
      end

      it "is valid for a user to have comments on more than one application" do
        create(:comment, application: create(:application), user:, published: false)
        comment = build(:comment, application: create(:application), user:, published: false)
        expect(comment).to be_valid
      end
    end

    it "is valid to have more than one published comment on an application for a user" do
      create(:comment, application:, user:, published: true)
      comment = build(:comment, application:, user:, published: true)
      expect(comment).to be_valid
    end
  end
end
