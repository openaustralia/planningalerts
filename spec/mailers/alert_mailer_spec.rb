# frozen_string_literal: true

require "spec_helper"

describe AlertMailer do
  let(:alert) do
    create(:alert,
           user: create(:user, email: "matthew@openaustralia.org"),
           address: "24 Bruce Rd, Glenbrook NSW 2773",
           lat: 1.0, lng: 2.0, radius_meters: 800,
           id: 1)
  end

  let(:a1) do
    location1 = Location.new(lat: 0.1, lng: 0.2)
    mock_model(Application,
               address: "Foo Street, Bar", council_reference: "a1", description: "Knock something down", id: 1,
               lat: location1.lat, lng: location1.lng, location: location1)
  end

  let(:a2) do
    location2 = Location.new(lat: 0.3, lng: 0.4)
    mock_model(Application,
               address: "Bar Street, Foo", council_reference: "a2", description: "Put something up", id: 2,
               lat: location2.lat, lng: location2.lng, location: location2)
  end

  let(:a3) do
    create(:geocoded_application, address: "2 Foo Parade, Glenbrook NSW 2773", id: 3)
  end

  let(:c1) do
    create(:comment, text: "I think this is a great idea", name: "Matthew Landauer", application: a3, id: 1)
  end

  let(:c2) do
    create(
      :comment, name: "Jack Smith", application: a3, id: 2, text: <<~COMMENT
        Carles typewriter officia, cillum ethical elit swag. Consequat cillum yr wes anderson. 3 wolf moon blog iphone, pickled irure skateboard mcsweeney's seitan keffiyeh wayfarers. Jean shorts sriracha sed laborum. Next level forage flexitarian id. Mixtape sriracha sartorial beard ut, salvia adipisicing veniam wayfarers bushwick ullamco 8-bit incididunt. Scenester excepteur dreamcatcher, truffaut organic placeat esse post-ironic carles cupidatat nihil butcher sartorial fanny pack lo-fi.

        Cillum ethnic single-origin coffee labore, sriracha fixie jean shorts freegan. Odd future aesthetic tempor, mustache bespoke gastropub dolore polaroid salvia helvetica. Kogi chambray cardigan sunt single-origin coffee. Cardigan echo park master cleanse craft beer. Carles sunt selvage, beard gastropub artisan chillwave odio VHS street art you probably haven't heard of them gentrify mixtape aesthetic. Salvia chambray anim occupy echo park est. Pork belly sint post-ironic ennui, PBR vero culpa readymade cardigan laboris.
      COMMENT
    )
  end

  before do
    allow(alert).to receive(:confirm_id).and_return("abcdef")
  end

  describe "when sending a planning alert with one new comment" do
    let(:email) { described_class.alert(alert:, comments: [c1]) }

    it "uses the singular in the comment line" do
      expect(email.subject).to eq("1 new comment on planning applications near #{alert.address}")
    end

    it "has the unsubscribe header" do
      expect(email.header["List-Unsubscribe"].to_s).to eq("<https://dev.planningalerts.org.au/alerts/abcdef/unsubscribe>")
      expect(email.header["List-Unsubscribe-Post"].to_s).to eq("List-Unsubscribe=One-Click")
    end
  end

  describe "when sending a planning alert with two new comments" do
    let(:email) { described_class.alert(alert:, comments: [c1, c2]) }

    it "uses the plural in the comment line" do
      expect(email.subject).to eq("2 new comments on planning applications near #{alert.address}")
    end
  end

  describe "when send a planning alert with one new comment and two new planning applications" do
    let(:email) { described_class.alert(alert:, applications: [a1, a2], comments: [c1]) }

    it "tells you about both in the comment line" do
      expect(email.subject).to eq("1 new comment and 2 new planning applications near #{alert.address}")
    end
  end

  describe "when sending a planning alert with one new planning application" do
    let(:email) { described_class.alert(alert:, applications: [a1]) }

    it "uses the singular (application) in the subject line" do
      expect(email.subject).to eq("1 new planning application near #{alert.address}")
    end
  end

  describe "when sending a planning alert with two new planning applications" do
    context "when the theme is Default" do
      let(:email) { described_class.alert(alert:, applications: [a1, a2]) }

      it "is sent to the user's email address" do
        expect(email.to).to eq([alert.email])
      end

      it "is from the planningalerts no reply email address" do
        expect(email.from).to eq(["no-reply@planningalerts.org.au"])
        # @email.from_addrs.first.name.should == "PlanningAlerts.org.au"
      end

      it "has a sensible subject line" do
        expect(email.subject).to eq("2 new planning applications near #{alert.address}")
      end

      context "with HTML emails" do
        let(:html_body) { email.html_part.body.to_s }

        it "contains application descriptions" do
          expect(html_body).to have_content "Knock something down"
          expect(html_body).to have_content "Put something up"
        end
      end
    end
  end
end
