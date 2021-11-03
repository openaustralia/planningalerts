# frozen_string_literal: true

require "spec_helper"

describe AlertMailer do
  before do
    @alert = create(:alert,
                    email: "matthew@openaustralia.org", address: "24 Bruce Rd, Glenbrook NSW 2773",
                    lat: 1.0, lng: 2.0, radius_meters: 800)
    allow(@alert).to receive(:confirm_id).and_return("abcdef")
    @original_emails_sent = Stat.emails_sent
    @original_applications_sent = Stat.applications_sent
    location1 = Location.new(lat: 0.1, lng: 0.2)
    @a1 = mock_model(Application,
                     address: "Foo Street, Bar", council_reference: "a1", description: "Knock something down", id: 1,
                     lat: location1.lat, lng: location1.lng, location: location1)
    location2 = Location.new(lat: 0.3, lng: 0.4)
    @a2 = mock_model(Application,
                     address: "Bar Street, Foo", council_reference: "a2", description: "Put something up", id: 2,
                     lat: location2.lat, lng: location2.lng, location: location2)
    @a3 = create(:geocoded_application, address: "2 Foo Parade, Glenbrook NSW 2773", id: 3)
    @c1 = create(:comment, text: "I think this is a great idea", name: "Matthew Landauer", application: @a3, id: 1)
    @c2 = create(
      :comment, name: "Jack Smith", application: @a3, id: 2, text: <<~COMMENT
        Carles typewriter officia, cillum ethical elit swag. Consequat cillum yr wes anderson. 3 wolf moon blog iphone, pickled irure skateboard mcsweeney's seitan keffiyeh wayfarers. Jean shorts sriracha sed laborum. Next level forage flexitarian id. Mixtape sriracha sartorial beard ut, salvia adipisicing veniam wayfarers bushwick ullamco 8-bit incididunt. Scenester excepteur dreamcatcher, truffaut organic placeat esse post-ironic carles cupidatat nihil butcher sartorial fanny pack lo-fi.

        Cillum ethnic single-origin coffee labore, sriracha fixie jean shorts freegan. Odd future aesthetic tempor, mustache bespoke gastropub dolore polaroid salvia helvetica. Kogi chambray cardigan sunt single-origin coffee. Cardigan echo park master cleanse craft beer. Carles sunt selvage, beard gastropub artisan chillwave odio VHS street art you probably haven't heard of them gentrify mixtape aesthetic. Salvia chambray anim occupy echo park est. Pork belly sint post-ironic ennui, PBR vero culpa readymade cardigan laboris.
      COMMENT
    )
  end

  describe "when sending a planning alert with one new comment" do
    let(:email) { described_class.alert(@alert, [], [@c1]) }

    it "uses the singular in the comment line" do
      expect(email.subject).to eq("1 new comment on planning applications near #{@alert.address}")
    end

    it "has the unsubscribe header" do
      expect(email.header["List-Unsubscribe"].to_s).to eq("<https://dev.planningalerts.org.au/alerts/abcdef/unsubscribe>")
    end
  end

  describe "when sending a planning alert with two new comments" do
    let(:email) { described_class.alert(@alert, [], [@c1, @c2]) }

    it "uses the plural in the comment line" do
      expect(email.subject).to eq("2 new comments on planning applications near #{@alert.address}")
    end

    it "nicelies format (in text) a list of multiple planning applications" do
      expect(email.text_part.body.to_s.strip).to eq Rails.root.join("spec/mailers/regression/alert_mailer/email3.txt").read.gsub("\n", "\r\n").strip
    end

    it "nicelies format (in HTML) a list of multiple planning applications" do
      expect(email.html_part.body.to_s).to eq(Rails.root.join("spec/mailers/regression/alert_mailer/email3.html").read.gsub("\n", "\r\n"))
    end
  end

  describe "when send a planning alert with one new comment and two new planning applications" do
    let(:email) { described_class.alert(@alert, [@a1, @a2], [@c1]) }

    it "tells you about both in the comment line" do
      expect(email.subject).to eq("1 new comment and 2 new planning applications near #{@alert.address}")
    end

    it "nicelies format (in text) a list of multiple planning applications" do
      expect(email.text_part.body.to_s.strip).to eq Rails.root.join("spec/mailers/regression/alert_mailer/email2.txt").read.gsub("\n", "\r\n").strip
    end

    it "nicelies format (in HTML) a list of multiple planning applications" do
      expect(email.html_part.body.to_s).to eq(Rails.root.join("spec/mailers/regression/alert_mailer/email2.html").read.gsub("\n", "\r\n"))
    end
  end

  describe "when sending a planning alert with one new planning application" do
    before do
      @email = described_class.alert(@alert, [@a1])
    end

    it "uses the singular (application) in the subject line" do
      expect(@email.subject).to eq("1 new planning application near #{@alert.address}")
    end
  end

  describe "when sending a planning alert with two new planning applications" do
    context "and the theme is Default" do
      before do
        @email = described_class.alert(@alert, [@a1, @a2])
      end

      it "is sent to the user's email address" do
        expect(@email.to).to eq([@alert.email])
      end

      it "is from the main planningalerts email address" do
        expect(@email.from).to eq(["contact@planningalerts.org.au"])
        # @email.from_addrs.first.name.should == "PlanningAlerts.org.au"
      end

      it "has a sensible subject line" do
        expect(@email.subject).to eq("2 new planning applications near #{@alert.address}")
      end

      it "is a multipart email" do
        expect(@email.body.parts.length).to eq(2)
      end

      context "Text email" do
        it "nicelies format a list of multiple planning applications" do
          expect(@email.text_part.body.to_s.strip).to eq Rails.root.join("spec/mailers/regression/alert_mailer/email1.txt").read.gsub("\n", "\r\n").strip
        end
      end

      context "HTML emails" do
        before do
          @html_body = @email.html_part.body.to_s
        end

        it "contains links to the applications" do
          expect(@html_body).to have_link("Foo Street, Bar", href: "https://dev.planningalerts.org.au/applications/1?utm_campaign=view-application&utm_medium=email&utm_source=alerts")
          expect(@html_body).to have_link("Bar Street, Foo", href: "https://dev.planningalerts.org.au/applications/2?utm_campaign=view-application&utm_medium=email&utm_source=alerts")
        end

        it "contains application descriptions" do
          expect(@html_body).to have_content "Knock something down"
          expect(@html_body).to have_content "Put something up"
        end

        it "has a specific body" do
          expect(@html_body).to eq(Rails.root.join("spec/mailers/regression/alert_mailer/email1.html").read.gsub("\n", "\r\n"))
        end
      end
    end
  end

  describe ".new_signup_attempt_notice" do
    it "puts the address in the subject" do
      alert = build(:alert, address: "123 Lovely St, La La")
      email = described_class.new_signup_attempt_notice(alert)

      expect(email).to have_subject "Your subscription for 123 Lovely St, La La"
    end

    it "tells the user that we’ve recieved a new signup attempt" do
      alert = build(:alert, address: "123 Lovely St, La La")
      email = described_class.new_signup_attempt_notice(alert)

      expect(email.html_part.body.to_s).to have_content "We just received a new request to send PlanningAlerts for 123 Lovely St, La La\nto your email address."
      expect(email.text_part.body.to_s).to have_content "We just received a new request to send PlanningAlerts for 123 Lovely St, La La to your email address."
    end
  end
end
