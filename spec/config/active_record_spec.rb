# frozen_string_literal: true

require "spec_helper"

# Behaviour that depends on the Rails 7.2 framework defaults (config.load_defaults 7.2)
describe ActiveRecord do
  describe "PostgreSQL date decoding" do
    it "returns a Date from a raw query on a date" do
      expect(ActiveRecord::Base.connection.select_value("SELECT '2024-01-01'::date")).to eq Date.new(2024, 1, 1)
    end

    # Authority#new_applications_per_week looks these keys up as Dates
    it "returns Date keys when grouping by a date expression" do
      create(:geocoded_application, date_scraped: Time.zone.local(2024, 1, 3))
      keys = Application.group("DATE(first_date_scraped) - CAST(EXTRACT(DOW FROM first_date_scraped) AS INT)").count.keys
      expect(keys).to eq [Date.new(2023, 12, 31)]
    end
  end

  describe "migration timestamps" do
    it "rejects a migration dated more than a day ahead" do
      Dir.mktmpdir do |dir|
        FileUtils.touch(File.join(dir, "#{2.days.from_now.utc.strftime('%Y%m%d%H%M%S')}_add_something.rb"))
        expect { ActiveRecord::MigrationContext.new(dir).migrations }
          .to raise_error(ActiveRecord::InvalidMigrationTimestampError)
      end
    end

    it "accepts every migration already in db/migrate" do
      expect { ActiveRecord::MigrationContext.new(Rails.root.join("db/migrate").to_s).migrations }.not_to raise_error
    end
  end
end
