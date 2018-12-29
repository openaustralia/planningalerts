# frozen_string_literal: true

require "spec_helper"

describe Authority do
  describe "validations" do
    it "should ensure a unique short_name" do
      existing_authority = create(:authority, short_name: "Existing")
      new_authority = build(:authority, short_name: "Existing")

      expect(existing_authority.valid?).to eq true

      expect(new_authority.valid?).to eq false
      expect(new_authority.errors.messages[:short_name]).to eq(["has already been taken"])
    end

    it "unique short name should be case insensitive" do
      create(:authority, short_name: "Existing")
      new_authority = build(:authority, short_name: "existing")

      expect(new_authority.valid?).to eq false
      expect(new_authority.errors.messages[:short_name]).to eq(["has already been taken"])
    end
  end

  describe "detecting authorities with old applications" do
    before :each do
      @a1 = create(:authority)
      @a2 = create(:authority)
      create(:geocoded_application, authority: @a1, date_scraped: 3.weeks.ago)
      create(:geocoded_application, authority: @a2)
    end

    it "should report that a scraper is broken if it hasn't received a DA in over two weeks" do
      expect(@a1.broken?).to eq true
    end

    it "should not report that a scraper is broken if it has received a DA in less than two weeks" do
      expect(@a2.broken?).to eq false
    end
  end

  describe "short name encoded" do
    before :each do
      @a1 = create(:authority, short_name: "Blue Mountains", full_name: "Blue Mountains City Council")
      @a2 = create(:authority, short_name: "Blue Mountains (new one)", full_name: "Blue Mountains City Council (fictional new one)")
    end

    it "should be constructed by replacing space by underscores and making it all lowercase" do
      expect(@a1.short_name_encoded).to eq "blue_mountains"
    end

    it "should remove any non-word characters (except for underscore)" do
      expect(@a2.short_name_encoded).to eq "blue_mountains_new_one"
    end

    it "should find a authority by the encoded name" do
      expect(Authority.find_short_name_encoded("blue_mountains")).to eq @a1
      expect(Authority.find_short_name_encoded("blue_mountains_new_one")).to eq @a2
    end
  end

  describe "#write_to_councillors_enabled?" do
    context "when it is globally not enabled" do
      around do |test|
        with_modified_env COUNCILLORS_ENABLED: nil do
          test.run
        end
      end

      context "and it is disabled on the authority" do
        let(:authority) { build_stubbed(:authority, write_to_councillors_enabled: false) }

        it { expect(authority.write_to_councillors_enabled?).to eq false }
      end

      context "and it is enabled on the authority" do
        let(:authority) { build_stubbed(:authority, write_to_councillors_enabled: true) }

        it { expect(authority.write_to_councillors_enabled?).to eq false }
      end
    end

    context "when it is globally enabled" do
      around do |test|
        with_modified_env COUNCILLORS_ENABLED: "true" do
          test.run
        end
      end

      context "and it is disabled on the authority" do
        let(:authority) { build_stubbed(:authority, write_to_councillors_enabled: false) }

        it { expect(authority.write_to_councillors_enabled?).to eq false }
      end

      context "and it is enabled on the authority" do
        let(:authority) { build_stubbed(:authority, write_to_councillors_enabled: true) }

        it { expect(authority.write_to_councillors_enabled?).to eq true }
      end
    end
  end

  describe "#comments_per_week" do
    let(:authority) { create(:authority) }

    before :each do
      Timecop.freeze(Time.zone.local(2016, 1, 5))
    end

    after :each do
      Timecop.return
    end

    context "when the authority has no applications" do
      it { expect(authority.comments_per_week).to eq [] }
    end

    context "when the authority has applications" do
      before :each do
        create(
          :geocoded_application,
          authority: authority,
          date_scraped: Date.new(2015, 12, 24),
          id: 1
        )
      end

      context "but no comments" do
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
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2015, 12, 26))
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2015, 12, 26))
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2015, 12, 26))
        create(:confirmed_comment, application_id: 1, confirmed_at: Date.new(2016, 1, 4))

        expect(authority.comments_per_week).to eq [
          [Date.new(2015, 12, 20), 3],
          [Date.new(2015, 12, 27), 0],
          [Date.new(2016, 1, 3), 1]
        ]
      end
    end
  end

  describe "#load_councillors" do
    let(:popolo) do
      popolo_file = Rails.root.join("spec", "fixtures", "local_councillor_popolo.json")
      EveryPolitician::Popolo.read(popolo_file)
    end

    around do |example|
      VCR.use_cassette("planningalerts") do
        example.run
      end
    end

    context "when the authority has two valid councillors" do
      subject(:authority) { create(:authority, full_name: "Albury City Council") }

      it "loads 2 councillors" do
        authority.load_councillors(popolo)

        expect(authority.councillors.count).to eql 2
      end

      it "loads councillors and their attributes" do
        authority.load_councillors(popolo)

        kevin = Councillor.find_by(name: "Kevin Mack")
        expect(kevin.present?).to be true
        expect(kevin.email).to eql "kevin@albury.nsw.gov.au"
        expect(kevin.image_url).to eql "https://australian-local-councillors-images.s3.amazonaws.com/albury_city_council/kevin_mack-80x88.jpg"
        expect(kevin.party).to be_nil
        expect(kevin.current).to be true
        expect(Councillor.find_by(name: "Ross Jackson").party).to eql "Liberal"
      end

      it "updates an existing councillor" do
        councillor = create(:councillor,
                            authority: authority,
                            name: "Kevin Mack",
                            image_url: "https://old_image.jpg",
                            email: "old_address@example.com",
                            popolo_id: "authority/old_id",
                            party: "The Old Parties")

        authority.load_councillors(popolo)

        councillor.reload
        expect(councillor.email).to eql "kevin@albury.nsw.gov.au"
        expect(councillor.image_url).to eql "https://australian-local-councillors-images.s3.amazonaws.com/albury_city_council/kevin_mack-80x88.jpg"
        expect(councillor.popolo_id).to eql "albury_city_council/kevin_mack"
        expect(councillor.party).to be_nil
      end

      it "uses the cached image url when it’s available" do
        cached_image_url = "https://australian-local-councillors-images.s3.amazonaws.com/albury_city_council/kevin_mack-80x88.jpg"

        authority.load_councillors(popolo)

        councillor = Councillor.find_by(name: "Kevin Mack")
        expect(councillor.image_url).to eql cached_image_url
      end

      it "does not use popolo source image url if there is no cached version" do
        armidale = create(:authority, full_name: "Armidale Dumaresq Council")

        armidale.load_councillors(popolo)

        councillor = Councillor.find_by(name: "Daryl Betteridge")
        expect(councillor.image_url).to be_nil
      end

      context "when a person is still a councillor" do
        around do |test|
          Timecop.freeze(2016, 9, 2) { test.run }
        end

        it "sets them as current" do
          armidale = create(:authority, full_name: "Armidale Dumaresq Council")

          armidale.load_councillors(popolo)

          councillor = Councillor.find_by(name: "Daryl Betteridge")
          expect(councillor.current?).to be true
        end
      end

      context "when a person is no longer a councillor" do
        around do |test|
          Timecop.freeze(2016, 12, 10) { test.run }
        end

        it "loads them and sets them as not current" do
          armidale = create(:authority, full_name: "Armidale Dumaresq Council")

          armidale.load_councillors(popolo)

          councillor = Councillor.find_by(name: "Daryl Betteridge")
          expect(councillor.current?).to be false
        end

        it "updates them as not current" do
          armidale = create(:authority, full_name: "Armidale Dumaresq Council")
          existing_councillor = create(
            :councillor,
            authority: armidale,
            name: "Daryl Betteridge",
            current: true
          )

          armidale.load_councillors(popolo)

          expect(existing_councillor.reload.current?).to be false
        end
      end
    end

    context "when the authority has an invalid councillor" do
      it "returns a Councillor with errors" do
        armidale = create(:authority, full_name: "Armidale Dumaresq Council")

        invalid_councillor = armidale.load_councillors(popolo).last

        expect(invalid_councillor).to_not be_valid
        expect(invalid_councillor.errors).to include :email
        expect(invalid_councillor.errors[:email]).to eql ["can't be blank"]
      end
    end
  end

  describe "#popolo_url" do
    it { expect(build(:authority, state: "NSW").popolo_url).to eq "https://raw.githubusercontent.com/openaustralia/australian_local_councillors_popolo/master/data/NSW/local_councillor_popolo.json" }
  end
end
