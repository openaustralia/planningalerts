require 'spec_helper'

describe Authority do
  describe "detecting authorities with old applications" do
    before :each do
      @a1 = create(:authority)
      @a2 = create(:authority)
      VCR.use_cassette('planningalerts') do
        create(:application, authority: @a1, date_scraped: 3.weeks.ago)
        create(:application, authority: @a2)
      end
    end

    it "should report that a scraper is broken if it hasn't received a DA in over two weeks" do
      @a1.broken?.should == true
    end

    it "should not report that a scraper is broken if it has received a DA in less than two weeks" do
      @a2.broken?.should == false
    end
  end

  describe "short name encoded" do
    before :each do
      @a1 = create(:authority, short_name: "Blue Mountains", full_name: "Blue Mountains City Council")
      @a2 = create(:authority, short_name: "Blue Mountains (new one)", full_name: "Blue Mountains City Council (fictional new one)")
    end

    it "should be constructed by replacing space by underscores and making it all lowercase" do
      @a1.short_name_encoded.should == "blue_mountains"
    end

    it "should remove any non-word characters (except for underscore)" do
      @a2.short_name_encoded.should == "blue_mountains_new_one"
    end

    it "should find a authority by the encoded name" do
      Authority.find_by_short_name_encoded("blue_mountains").should == @a1
      Authority.find_by_short_name_encoded("blue_mountains_new_one").should == @a2
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

    def with_modified_env(options, &block)
      ClimateControl.modify(options, &block)
    end
  end

  describe "#comments_per_week" do
    let(:authority) { create(:authority) }

    before :each do
      Timecop.freeze(Time.local(2016, 1, 5))
    end

    after :each do
      Timecop.return
    end

    context "when the authority has no applications" do
      it { expect(authority.comments_per_week).to eq [] }
    end

    context "when the authority has applications" do
      before :each do
        VCR.use_cassette('planningalerts') do
          create(
            :application,
            authority: authority,
            date_scraped: Date.new(2015,12,24),
            id: 1
          )
        end
      end

      context "but no comments" do
        it { expect(authority.comments_per_week).to eq [
          [ Date.new(2015,12,20), 0 ],
          [ Date.new(2015,12,27), 0 ],
          [ Date.new(2016,1,3), 0 ]
        ]}
      end

      it "doesn't count hidden or unconfirmed comments" do
        create(:unconfirmed_comment, application_id: 1, updated_at: Date.new(2015,12,26))
        create(:unconfirmed_comment, application_id: 1, updated_at: Date.new(2015,12,26))
        create(:unconfirmed_comment, application_id: 1, updated_at: Date.new(2015,12,26))
        create(:unconfirmed_comment, application_id: 1, updated_at: Date.new(2016,1,4))
        create(:confirmed_comment, hidden: true, application_id: 1, updated_at: Date.new(2016,1,4))

        expect(authority.comments_per_week).to eq [
          [ Date.new(2015,12,20), 0 ],
          [ Date.new(2015,12,27), 0 ],
          [ Date.new(2016,1,3), 0 ]
        ]
      end

      it "returns count of visible comments for each week since the first application was scraped" do
        create(:confirmed_comment, application_id: 1, updated_at: Date.new(2015,12,26))
        create(:confirmed_comment, application_id: 1, updated_at: Date.new(2015,12,26))
        create(:confirmed_comment, application_id: 1, updated_at: Date.new(2015,12,26))
        create(:confirmed_comment, application_id: 1, updated_at: Date.new(2016,1,4))

        expect(authority.comments_per_week).to eq [
          [ Date.new(2015,12,20), 3 ],
          [ Date.new(2015,12,27), 0 ],
          [ Date.new(2016,1,3), 1 ]
        ]
      end
    end
  end

  describe "#scraper_data_original_style" do
    context "authority with an xml feed with no date in the url" do
      let (:authority) { build(:authority) }
      it "should get the feed date only once" do
        authority.should_receive(:open_url_safe).once
        authority.scraper_data_original_style("http://foo.com", Date.new(2001,1,1), Date.new(2001,1,3), double)
      end
    end
  end

  describe "#load_councillors" do
    let(:popolo) do
      popolo_file = Rails.root.join("spec", "fixtures", "local_councillor_popolo.json")
      EveryPolitician::Popolo::read(popolo_file)
    end

    context "when the authority has two valid councillors" do
      subject(:authority) { create(:authority, full_name: "Albury City Council") }

      it "should load 2 councillors" do
        authority.load_councillors(popolo)

        expect(authority.councillors.count).to eql 2
      end

      it "loads councillors and their attributes" do
        authority.load_councillors(popolo)

        kevin = Councillor.find_by(name: "Kevin Mack")
        expect(kevin.present?).to be_true
        expect(kevin.email).to eql "kevin@albury.nsw.gov.au"
        expect(kevin.image_url).to eql "https://example.com/kevin.jpg"
        expect(kevin.party).to be_nil
        expect(Councillor.find_by(name: "Ross Jackson").party).to eql "Liberal"
      end

      it "updates an existing councillor" do
        councillor = create(:councillor, authority: authority,
                            name: "Kevin Mack",
                            email: "old_address@example.com",
                            party: "The Old Parties")

        authority.load_councillors(popolo)

        councillor.reload
        expect(councillor.email).to eql "kevin@albury.nsw.gov.au"
        expect(councillor.image_url).to eql "https://example.com/kevin.jpg"
        expect(councillor.party).to be_nil
      end
    end

    context "when the authority has an invalid councillor" do
      it "returns a Councillor with errors" do
        armidale = create(:authority, full_name: "Armidale Dumaresq Council")

        invalid_councillor = armidale.load_councillors(popolo).last

        expect(invalid_councillor).to_not be_valid
        expect(invalid_councillor.errors).to include :email
        expect(invalid_councillor.errors.get(:email)).to eql ["can't be blank"]
      end
    end
  end

  describe "#popolo_url" do
    it { expect(build(:authority, state: "NSW").popolo_url).to eq "https://raw.githubusercontent.com/openaustralia/australian_local_councillors_popolo/master/nsw_local_councillor_popolo.json" }
  end
end
