# frozen_string_literal: true

require "spec_helper"

describe InvokeRakeTaskJob do
  let(:received) { [] }

  before do
    received = self.received
    Rake::Task.define_task("spec:invoke_rake_task_job", [:value]) { |_task, args| received << args[:value] }
  end

  after { Rake::Task["spec:invoke_rake_task_job"].clear }

  it "runs the named rake task with its argument" do
    described_class.new.perform("task" => "spec:invoke_rake_task_job", "args" => "hello")

    expect(received).to eq ["hello"]
  end

  it "runs the task again each time, as cron does" do
    2.times { described_class.new.perform("task" => "spec:invoke_rake_task_job", "args" => "again") }

    expect(received).to eq %w[again again]
  end
end
