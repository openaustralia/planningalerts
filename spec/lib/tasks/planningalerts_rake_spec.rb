# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "planningalerts bulk moderation rake tasks", type: :task do
  let(:authority) { create(:authority) }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  around do |example|
    original = ENV.fetch("REASON", nil)
    ENV.delete("REASON")
    example.run
  ensure
    if original.nil?
      ENV.delete("REASON")
    else
      ENV["REASON"] = original
    end
  end

  def run_task(name, *args)
    task = Rake::Task[name]
    task.reenable
    task.invoke(*args)
  end

  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original
  end

  describe "planningalerts:bulk_hide_applications" do
    let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }

    it "raises when REASON is not set" do
      expect do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "PA1")
      end.to raise_error(/REASON can't be blank/)
    end

    it "raises when REASON is blank" do
      ENV["REASON"] = "   "
      expect do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "PA1")
      end.to raise_error(/REASON can't be blank/)
    end

    it "raises on an unknown mode" do
      ENV["REASON"] = "Duplicate record"
      expect do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "PA1", "exceute")
      end.to raise_error(/Unknown mode: exceute/)
    end

    it "raises when the prefix is blank" do
      ENV["REASON"] = "Duplicate record"
      expect do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "")
      end.to raise_error(/prefix can't be blank/)
    end

    it "dry runs by default, changing nothing and showing how to execute" do
      ENV["REASON"] = "Duplicate record"
      output = capture_stdout do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "PA1")
      end
      expect(application.reload.hidden).to be false
      expect(output).to include "DRY RUN - nothing was changed"
      expect(output).to include "Would hide 1 application(s):"
      expect(output).to include "PA123 (id #{application.id})"
      expect(output).to include "This was a dry run. To actually hide run the task again with execute, e.g."
      expect(output).to include "REASON=\"Duplicate record\" rake planningalerts:bulk_hide_applications[#{authority.id},PA1,execute]"
    end

    it "hides the matching applications with the reason when executing" do
      ENV["REASON"] = "Duplicate record"
      output = capture_stdout do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "PA1", "execute")
      end
      expect(application.reload.hidden).to be true
      expect(application.hidden_reason).to eq "Duplicate record"
      expect(output).to include "Hid 1 application(s):"
      expect(output).not_to include "DRY RUN"
    end

    it "reports the number of comments affected" do
      create(:published_comment, application:)
      ENV["REASON"] = "Duplicate record"
      output = capture_stdout do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "PA1", "execute")
      end
      expect(output).to include "PA123 (id #{application.id}) - A test address - has 1 comment(s)"
    end

    it "reports applications skipped because they are already hidden" do
      create(:geocoded_application, :hidden, authority:, council_reference: "PA124")
      ENV["REASON"] = "Duplicate record"
      output = capture_stdout do
        run_task("planningalerts:bulk_hide_applications", authority.id.to_s, "PA1", "execute")
      end
      expect(output).to include(
        "Skipped 1 application(s) because they are already hidden (their existing hidden reason is kept):"
      )
    end
  end

  describe "planningalerts:bulk_unhide_applications" do
    let!(:application) do
      create(:geocoded_application, :hidden, authority:, council_reference: "PA123",
                                             hidden_reason: "Published in error")
    end

    it "dry runs by default, changing nothing" do
      output = capture_stdout do
        run_task("planningalerts:bulk_unhide_applications", authority.id.to_s, "PA1")
      end
      expect(application.reload.hidden).to be true
      expect(application.hidden_reason).to eq "Published in error"
      expect(output).to include "DRY RUN - nothing was changed"
      expect(output).to include "Would unhide 1 application(s):"
      expect(output).to include "rake planningalerts:bulk_unhide_applications[#{authority.id},PA1,execute]"
    end

    it "unhides the matching applications and clears the reason when executing" do
      output = capture_stdout do
        run_task("planningalerts:bulk_unhide_applications", authority.id.to_s, "PA1", "execute")
      end
      expect(application.reload.hidden).to be false
      expect(application.hidden_reason).to be_nil
      expect(output).to include "Unhid 1 application(s):"
    end

    it "reports applications skipped because they are not hidden" do
      create(:geocoded_application, authority:, council_reference: "PA124")
      output = capture_stdout do
        run_task("planningalerts:bulk_unhide_applications", authority.id.to_s, "PA1", "execute")
      end
      expect(output).to include "Skipped 1 application(s) because they are not hidden:"
    end
  end

  describe "planningalerts:bulk_delete_applications" do
    let!(:application) { create(:geocoded_application, authority:, council_reference: "PA123") }

    it "still deletes matching applications when executing" do
      output = capture_stdout do
        run_task("planningalerts:bulk_delete_applications", authority.id.to_s, "PA1", "execute")
      end
      expect(Application.exists?(application.id)).to be false
      expect(output).to include "Deleted 1 application(s):"
    end

    it "still dry runs by default with the same output format" do
      output = capture_stdout do
        run_task("planningalerts:bulk_delete_applications", authority.id.to_s, "PA1")
      end
      expect(Application.exists?(application.id)).to be true
      expect(output).to include "DRY RUN - nothing was changed"
      expect(output).to include "Would delete 1 application(s):"
      expect(output).to include "This was a dry run. To actually delete run the task again with execute, e.g."
      expect(output).to include "rake planningalerts:bulk_delete_applications[#{authority.id},PA1,execute]"
    end

    it "still raises on an unknown option" do
      expect do
        run_task("planningalerts:bulk_delete_applications", authority.id.to_s, "PA1", "execute", "delete_comment")
      end.to raise_error(/Unknown option: delete_comment/)
    end
  end
end
