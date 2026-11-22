# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "db:stats rake task", type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["db:stats"].reenable
  end

  it "lists each table's row count and size, with a total" do
    create(:authority)

    expect { Rake::Task["db:stats"].invoke }
      .to output(/^authorities\s+1\s+[\d.]+ MB$.*^TOTAL\s+\d+\s+[\d.]+ MB$.*approximate count/m).to_stdout
  end
end
