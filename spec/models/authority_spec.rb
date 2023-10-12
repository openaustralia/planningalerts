# frozen_string_literal: true

require "spec_helper"

describe Authority do
  describe "validations" do
    let!(:existing_authority) { create(:authority, short_name: "Existing Council") }

    it "ensures a unique short_name" do
      new_authority = build(:authority, short_name: "Existing Council")

      expect(existing_authority).to be_valid

      expect(new_authority).not_to be_valid
      expect(new_authority.errors.messages[:short_name]).to eq(["is not unique when encoded"])
    end

    it "unique short name should be case insensitive" do
      new_authority = build(:authority, short_name: "existing council")

      expect(new_authority).not_to be_valid
      expect(new_authority.errors.messages[:short_name]).to eq(["is not unique when encoded"])
    end

    it "allows a different short_name" do
      new_authority = build(:authority, short_name: "Different Council")
      expect(new_authority).to be_valid
    end

    it "does not allow a name that encodes to the same string" do
      new_authority = build(:authority, short_name: "existing_council")
      expect(new_authority).not_to be_valid
      expect(new_authority.errors.messages[:short_name]).to eq(["is not unique when encoded"])
    end
  end

  describe "detecting authorities with old applications" do
    let(:a1) { create(:authority) }
    let(:a2) { create(:authority) }

    before do
      create(:geocoded_application, authority: a1, date_scraped: 3.weeks.ago)
      create(:geocoded_application, authority: a2)
    end

    it "reports that a scraper is broken if it hasn't received a DA in over two weeks" do
      expect(a1.broken?).to be true
    end

    it "does not report that a scraper is broken if it has received a DA in less than two weeks" do
      expect(a2.broken?).to be false
    end
  end

  describe "short name encoded" do
    let!(:a1) { create(:authority, short_name: "Blue Mountains", full_name: "Blue Mountains City Council") }
    let!(:a2) { create(:authority, short_name: "Blue Mountains (new one)", full_name: "Blue Mountains City Council (fictional new one)") }

    it "is constructed by replacing space by underscores and making it all lowercase" do
      expect(a1.short_name_encoded).to eq "blue_mountains"
    end

    it "removes any non-word characters (except for underscore)" do
      expect(a2.short_name_encoded).to eq "blue_mountains_new_one"
    end

    it "finds a authority by the encoded name" do
      expect(described_class.find_short_name_encoded("blue_mountains")).to eq a1
      expect(described_class.find_short_name_encoded("blue_mountains_new_one")).to eq a2
    end
  end

  describe "#comments_per_week" do
    let(:authority) { create(:authority) }

    before do
      Timecop.freeze(Time.zone.local(2016, 1, 5))
    end

    after do
      Timecop.return
    end

    context "when the authority has no applications" do
      it { expect(authority.comments_per_week).to eq [] }
    end

    context "when the authority has applications" do
      before do
        create(
          :geocoded_application,
          authority:,
          date_scraped: Date.new(2015, 12, 24),
          id: 1
        )
      end

      context "when no comments" do
        it {
          expect(authority.comments_per_week).to eq [
            [Date.new(2015, 12, 20), 0],
            [Date.new(2015, 12, 27), 0],
            [Date.new(2016, 1, 3), 0]
          ]
        }
      end

      it "doesn't count hidden or unconfirmed comments" do
        create(:unconfirmed_comment, application_id: 1, created_at: Date.new(2015, 12, 26))
        create(:unconfirmed_comment, application_id: 1, created_at: Date.new(2015, 12, 26))
        create(:unconfirmed_comment, application_id: 1, created_at: Date.new(2015, 12, 26))
        create(:unconfirmed_comment, application_id: 1, created_at: Date.new(2016, 1, 4))
        create(:confirmed_comment, hidden: true, application_id: 1, confirmed_at: Date.new(2016, 1, 4))

        expect(authority.comments_per_week).to eq [
          [Date.new(2015, 12, 20), 0],
          [Date.new(2015, 12, 27), 0],
          [Date.new(2016, 1, 3), 0]
        ]
      end

      it "returns count of visible comments for each week since the first application was scraped" do
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2015, 12, 26), previewed_at: Date.new(2015, 12, 26))
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2015, 12, 26), previewed_at: Date.new(2015, 12, 26))
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2015, 12, 26), previewed_at: Date.new(2015, 12, 26))
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2016, 1, 4), previewed_at: Date.new(2016, 1, 4))

        expect(authority.comments_per_week).to eq [
          [Date.new(2015, 12, 20), 3],
          [Date.new(2015, 12, 27), 0],
          [Date.new(2016, 1, 3), 1]
        ]
      end
    end
  end
end
