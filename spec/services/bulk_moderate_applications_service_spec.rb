# frozen_string_literal: true

require "spec_helper"

describe BulkModerateApplicationsService do
  let(:authority) { create(:authority) }

  def bulk_delete(prefix: "PA1", dry_run: true, delete_comments: false)
    described_class.call(
      authority:,
      council_reference_prefix: prefix,
      mode: BulkModerateApplicationsService::Mode::Delete,
      dry_run:,
      delete_comments:
    )
  end

  def bulk_hide(prefix: "PA1", dry_run: true, hidden_reason: "Duplicate record")
    described_class.call(
      authority:,
      council_reference_prefix: prefix,
      mode: BulkModerateApplicationsService::Mode::Hide,
      dry_run:,
      hidden_reason:
    )
  end

  def bulk_unhide(prefix: "PA1", dry_run: true)
    described_class.call(
      authority:,
      council_reference_prefix: prefix,
      mode: BulkModerateApplicationsService::Mode::Unhide,
      dry_run:
    )
  end

  describe "delete mode" do
    it "raises when the prefix is blank" do
      expect { bulk_delete(prefix: "") }.to raise_error(ArgumentError)
    end

    context "with applications from different authorities and references" do
      let!(:matching) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:other_reference) { create(:geocoded_application, authority:, council_reference: "PA456") }
      let!(:other_authority) { create(:geocoded_application, council_reference: "PA124") }

      it "only matches applications for the given authority with the given prefix" do
        result = bulk_delete
        expect(result.changed.map(&:id)).to eq [matching.id]
        expect(result.skipped_comments).to be_empty
        expect(result.skipped_redirect_target).to be_empty
      end

      it "does not delete anything in a dry run" do
        expect { bulk_delete }.not_to change(Application, :count)
      end

      it "deletes only the matching application when executing" do
        expect { bulk_delete(dry_run: false) }.to change(Application, :count).by(-1)
        expect(Application.exists?(matching.id)).to be false
        expect(Application.exists?(other_reference.id)).to be true
        expect(Application.exists?(other_authority.id)).to be true
      end

      it "deletes the application versions too" do
        expect { bulk_delete(dry_run: false) }.to change(ApplicationVersion, :count).by(-1)
      end

      it "does not treat SQL wildcards in the prefix as wildcards" do
        result = bulk_delete(prefix: "PA%")
        expect(result.changed).to be_empty
      end
    end

    context "with an application that has comments" do
      let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:comment) { create(:published_comment, application:) }

      it "skips it and reports it by default" do
        result = bulk_delete(dry_run: false)
        expect(result.changed).to be_empty
        expect(result.skipped_comments.map(&:id)).to eq [application.id]
        expect(result.skipped_comments.first.comments_count).to eq 1
        expect(Application.exists?(application.id)).to be true
      end

      it "deletes it along with its comments when delete_comments is set" do
        result = bulk_delete(dry_run: false, delete_comments: true)
        expect(result.changed.map(&:id)).to eq [application.id]
        expect(Application.exists?(application.id)).to be false
        expect(Comment.exists?(comment.id)).to be false
      end

      it "reports it as deleted in a dry run with delete_comments but changes nothing" do
        result = nil
        expect { result = bulk_delete(delete_comments: true) }.not_to change(Comment, :count)
        expect(result.changed.map(&:id)).to eq [application.id]
      end
    end

    context "with an application that is the target of a redirect" do
      let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }

      before do
        create(:application_redirect, application_id: application.id + 1000, redirect_application: application)
      end

      it "skips it and reports it" do
        result = bulk_delete(dry_run: false)
        expect(result.changed).to be_empty
        expect(result.skipped_redirect_target.map(&:id)).to eq [application.id]
        expect(Application.exists?(application.id)).to be true
      end
    end

    it "raises when a hidden_reason is supplied" do
      expect do
        described_class.call(
          authority:,
          council_reference_prefix: "PA1",
          mode: BulkModerateApplicationsService::Mode::Delete,
          dry_run: true,
          hidden_reason: "Not relevant to deleting"
        )
      end.to raise_error(ArgumentError, /hidden_reason only applies when hiding/)
    end
  end

  describe "hide mode" do
    it "raises when the prefix is blank" do
      expect { bulk_hide(prefix: "") }.to raise_error(ArgumentError)
    end

    it "raises when the reason is nil" do
      expect { bulk_hide(hidden_reason: nil) }.to raise_error(ArgumentError, /hidden_reason can't be blank/)
    end

    it "raises when the reason is empty" do
      expect { bulk_hide(hidden_reason: "") }.to raise_error(ArgumentError, /hidden_reason can't be blank/)
    end

    it "raises when the reason is only whitespace" do
      expect { bulk_hide(hidden_reason: "   ") }.to raise_error(ArgumentError, /hidden_reason can't be blank/)
    end

    it "raises when delete_comments is combined with hiding" do
      expect do
        described_class.call(
          authority:,
          council_reference_prefix: "PA1",
          mode: BulkModerateApplicationsService::Mode::Hide,
          dry_run: true,
          delete_comments: true,
          hidden_reason: "Duplicate record"
        )
      end.to raise_error(ArgumentError, /delete_comments only applies when deleting/)
    end

    context "with applications from different authorities and references" do
      let!(:matching) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:other_reference) { create(:geocoded_application, authority:, council_reference: "PA456") }
      let!(:other_authority) { create(:geocoded_application, council_reference: "PA124") }

      it "only matches applications for the given authority with the given prefix" do
        result = bulk_hide
        expect(result.changed.map(&:id)).to eq [matching.id]
        expect(result.skipped_unchanged).to be_empty
      end

      it "changes nothing in a dry run" do
        bulk_hide
        expect(matching.reload.hidden).to be false
        expect(matching.hidden_reason).to be_nil
      end

      it "hides only the matching application with the given reason when executing" do
        bulk_hide(dry_run: false, hidden_reason: "Published in error")
        expect(matching.reload.hidden).to be true
        expect(matching.hidden_reason).to eq "Published in error"
        expect(other_reference.reload.hidden).to be false
        expect(other_authority.reload.hidden).to be false
      end

      it "does not delete anything" do
        expect { bulk_hide(dry_run: false) }.not_to change(Application, :count)
      end

      it "does not treat SQL wildcards in the prefix as wildcards" do
        result = bulk_hide(prefix: "PA%")
        expect(result.changed).to be_empty
      end
    end

    context "with an application that has comments" do
      let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:comment) { create(:published_comment, application:) }

      it "hides it rather than skipping it and reports the comments affected" do
        result = bulk_hide(dry_run: false)
        expect(result.changed.map(&:id)).to eq [application.id]
        expect(result.changed.first.comments_count).to eq 1
        expect(application.reload.hidden).to be true
      end

      it "leaves the comments untouched" do
        expect { bulk_hide(dry_run: false) }.not_to change(Comment, :count)
        expect(Comment.exists?(comment.id)).to be true
      end
    end

    context "with an application that is the target of a redirect" do
      let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }

      before do
        create(:application_redirect, application_id: application.id + 1000, redirect_application: application)
      end

      it "hides it rather than skipping it" do
        result = bulk_hide(dry_run: false)
        expect(result.changed.map(&:id)).to eq [application.id]
        expect(application.reload.hidden).to be true
      end
    end

    context "with an application that is already hidden" do
      let!(:visible) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:already_hidden) do
        create(:geocoded_application, :hidden, authority:, council_reference: "PA124",
                                               hidden_reason: "Hidden by hand in admin")
      end

      it "skips it and reports it" do
        result = bulk_hide(dry_run: false)
        expect(result.changed.map(&:id)).to eq [visible.id]
        expect(result.skipped_unchanged.map(&:id)).to eq [already_hidden.id]
      end

      it "does not overwrite its existing hidden reason" do
        bulk_hide(dry_run: false, hidden_reason: "A bulk reason")
        expect(already_hidden.reload.hidden_reason).to eq "Hidden by hand in admin"
      end

      it "is safe to run again after a partial run" do
        bulk_hide(dry_run: false)
        result = bulk_hide(dry_run: false)
        expect(result.changed).to be_empty
        expect(result.skipped_unchanged.map(&:id)).to contain_exactly(visible.id, already_hidden.id)
        expect(visible.reload.hidden).to be true
      end
    end

    context "with searchkick callbacks enabled" do
      # The test suite runs Searchkick.disable_callbacks globally so nothing
      # touches elasticsearch. Hiding needs to remove applications from the
      # search index, which relies on the service saving each record (rather
      # than using update_all) so that searchkick's callbacks fire. These
      # examples re-enable the callbacks with the reindex job stubbed out to
      # guard against that regressing.
      let!(:visible) { create(:geocoded_application, authority:, council_reference: "PA123") }
      let!(:already_hidden) { create(:geocoded_application, :hidden, authority:, council_reference: "PA124") }

      before do
        allow(Searchkick::ReindexV2Job).to receive(:perform_later)
      end

      it "enqueues a reindex for each application it hides" do
        Searchkick.callbacks(:async) do
          bulk_hide(dry_run: false)
        end
        expect(Searchkick::ReindexV2Job).to have_received(:perform_later)
          .with("Application", visible.id.to_s, any_args)
      end

      it "does not enqueue a reindex for applications it skips" do
        Searchkick.callbacks(:async) do
          bulk_hide(dry_run: false)
        end
        expect(Searchkick::ReindexV2Job).not_to have_received(:perform_later)
          .with("Application", already_hidden.id.to_s, any_args)
      end

      it "does not enqueue a reindex in a dry run" do
        Searchkick.callbacks(:async) do
          bulk_hide
        end
        expect(Searchkick::ReindexV2Job).not_to have_received(:perform_later)
      end

      it "enqueues a reindex for each application it unhides" do
        Searchkick.callbacks(:async) do
          bulk_unhide(dry_run: false)
        end
        expect(Searchkick::ReindexV2Job).to have_received(:perform_later)
          .with("Application", already_hidden.id.to_s, any_args)
      end
    end
  end

  describe "unhide mode" do
    it "raises when the prefix is blank" do
      expect { bulk_unhide(prefix: "") }.to raise_error(ArgumentError)
    end

    it "raises when a hidden_reason is supplied" do
      expect do
        described_class.call(
          authority:,
          council_reference_prefix: "PA1",
          mode: BulkModerateApplicationsService::Mode::Unhide,
          dry_run: true,
          hidden_reason: "Not relevant to unhiding"
        )
      end.to raise_error(ArgumentError, /hidden_reason only applies when hiding/)
    end

    context "with a mix of hidden and visible applications" do
      let!(:hidden) do
        create(:geocoded_application, :hidden, authority:, council_reference: "PA123",
                                               hidden_reason: "Published in error")
      end
      let!(:visible) { create(:geocoded_application, authority:, council_reference: "PA124") }
      let!(:hidden_other_authority) { create(:geocoded_application, :hidden, council_reference: "PA125") }

      it "changes nothing in a dry run" do
        result = bulk_unhide
        expect(result.changed.map(&:id)).to eq [hidden.id]
        expect(hidden.reload.hidden).to be true
        expect(hidden.hidden_reason).to eq "Published in error"
      end

      it "unhides only the matching hidden application and clears its reason" do
        bulk_unhide(dry_run: false)
        expect(hidden.reload.hidden).to be false
        expect(hidden.hidden_reason).to be_nil
        expect(hidden_other_authority.reload.hidden).to be true
      end

      it "skips applications that are not hidden and reports them" do
        result = bulk_unhide(dry_run: false)
        expect(result.changed.map(&:id)).to eq [hidden.id]
        expect(result.skipped_unchanged.map(&:id)).to eq [visible.id]
        expect(visible.reload.hidden).to be false
      end
    end
  end
end
