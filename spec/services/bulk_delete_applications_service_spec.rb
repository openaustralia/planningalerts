# frozen_string_literal: true

require "spec_helper"

describe BulkDeleteApplicationsService do
  let(:authority) { create(:authority) }

  def call(prefix: "PA1", dry_run: true, delete_comments: false)
    described_class.call(
      authority:,
      council_reference_prefix: prefix,
      dry_run:,
      delete_comments:
    )
  end

  describe ".call" do
    it "raises when the prefix is blank" do
      expect { call(prefix: "") }.to raise_error(ArgumentError)
    end

    context "with applications from different authorities and references" do
      let!(:matching) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:other_reference) { create(:geocoded_application, authority:, council_reference: "PA456") }
      let!(:other_authority) { create(:geocoded_application, council_reference: "PA124") }

      it "only matches applications for the given authority with the given prefix" do
        result = call
        expect(result.deleted.map(&:id)).to eq [matching.id]
        expect(result.skipped_comments).to be_empty
        expect(result.skipped_redirect_target).to be_empty
      end

      it "does not delete anything in a dry run" do
        expect { call }.not_to change(Application, :count)
      end

      it "deletes only the matching application when executing" do
        expect { call(dry_run: false) }.to change(Application, :count).by(-1)
        expect(Application.exists?(matching.id)).to be false
        expect(Application.exists?(other_reference.id)).to be true
        expect(Application.exists?(other_authority.id)).to be true
      end

      it "deletes the application versions too" do
        expect { call(dry_run: false) }.to change(ApplicationVersion, :count).by(-1)
      end

      it "does not treat SQL wildcards in the prefix as wildcards" do
        result = call(prefix: "PA%")
        expect(result.deleted).to be_empty
      end
    end

    context "with an application that has comments" do
      let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:comment) { create(:published_comment, application:) }

      it "skips it and reports it by default" do
        result = call(dry_run: false)
        expect(result.deleted).to be_empty
        expect(result.skipped_comments.map(&:id)).to eq [application.id]
        expect(result.skipped_comments.first.comments_count).to eq 1
        expect(Application.exists?(application.id)).to be true
      end

      it "deletes it along with its comments when delete_comments is set" do
        result = call(dry_run: false, delete_comments: true)
        expect(result.deleted.map(&:id)).to eq [application.id]
        expect(Application.exists?(application.id)).to be false
        expect(Comment.exists?(comment.id)).to be false
      end

      it "reports it as deleted in a dry run with delete_comments but changes nothing" do
        result = nil
        expect { result = call(delete_comments: true) }.not_to change(Comment, :count)
        expect(result.deleted.map(&:id)).to eq [application.id]
      end
    end

    context "with an application that is the target of a redirect" do
      let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }

      before do
        create(:application_redirect, application_id: application.id + 1000, redirect_application: application)
      end

      it "skips it and reports it" do
        result = call(dry_run: false)
        expect(result.deleted).to be_empty
        expect(result.skipped_redirect_target.map(&:id)).to eq [application.id]
        expect(Application.exists?(application.id)).to be true
      end
    end
  end
end
