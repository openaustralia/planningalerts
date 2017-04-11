require 'spec_helper'

describe AlertNotifier do
  before :each do
    @alert = create(:alert, email: "matthew@openaustralia.org", address: "24 Bruce Rd, Glenbrook NSW 2773",
      lat: 1.0, lng: 2.0, radius_meters: 800)
    allow(@alert).to receive(:confirm_id).and_return("abcdef")
    @original_emails_sent = Stat.emails_sent
    @original_applications_sent = Stat.applications_sent
    location1 = double("Location", lat: 0.1, lng: 0.2)
    @a1 = mock_model(Application, address: "Foo Street, Bar", council_reference: "a1", description: "Knock something down", id: 1,
        lat: location1.lat, lng: location1.lng, location: location1)
    location2 = double("Location", lat: 0.3, lng: 0.4)
    @a2 = mock_model(Application, address: "Bar Street, Foo", council_reference: "a2", description: "Put something up", id: 2,
        lat: location2.lat, lng: location2.lng, location: location2)
    @a3 = mock_model(Application, address: "2 Foo Parade, Glenbrook NSW 2773", id: 3)
    @c1 = create(:comment, text: "I think this is a great idea", name: "Matthew Landauer", application: @a3, id: 1)
    @c2 = create(:comment, name: "Jack Smith", application: @a3, id: 2, text: <<-EOF
Carles typewriter officia, cillum ethical elit swag. Consequat cillum yr wes anderson. 3 wolf moon blog iphone, pickled irure skateboard mcsweeney's seitan keffiyeh wayfarers. Jean shorts sriracha sed laborum. Next level forage flexitarian id. Mixtape sriracha sartorial beard ut, salvia adipisicing veniam wayfarers bushwick ullamco 8-bit incididunt. Scenester excepteur dreamcatcher, truffaut organic placeat esse post-ironic carles cupidatat nihil butcher sartorial fanny pack lo-fi.

Cillum ethnic single-origin coffee labore, sriracha fixie jean shorts freegan. Odd future aesthetic tempor, mustache bespoke gastropub dolore polaroid salvia helvetica. Kogi chambray cardigan sunt single-origin coffee. Cardigan echo park master cleanse craft beer. Carles sunt selvage, beard gastropub artisan chillwave odio VHS street art you probably haven't heard of them gentrify mixtape aesthetic. Salvia chambray anim occupy echo park est. Pork belly sint post-ironic ennui, PBR vero culpa readymade cardigan laboris.
    EOF
    )
    @c3 = create(:comment, name: "Natalie Black", application: @a3, id: 3, text: "Is this actually a good idea?")
    @c4 = create(:comment, name: "Natalie White", application: @a3, id: 4, text: "This is acutally a good idea.")
    @c5 = create(:comment, name: "Natalie Brown", application: @a3, id: 5, text: "How does this affect our neigbourhood?")
    @c6 = create(:comment, name: "Natalie Green", application: @a3, id: 6, text: "When is the townhall meeting?")
    @c7 = create(:comment, name: "Natalie Grey", application: @a3, id: 7, text: "I'm not sure this is a good idea?")
    @c8 = create(:comment, name: "Natalie Silver", application: @a3, id: 8, text: "I think it's an excellent idea.")
    @c9 = create(:comment, name: "Natalie Gold", application: @a3, id: 9, text: "I can't wait for this to happen.")
    @c10 = create(:comment, name: "Natalie Rose", application: @a3, id: 10, text: "I would like to have information session for the residents")
    @c11 = create(:comment, name: "Natalie Scarlet", application: @a3, id: 11, text: "Is this actually a good idea?")
  end

  describe "when sending a planning alert with one new comment" do
    let(:email) { AlertNotifier.alert("default", @alert, [], [@c1])}

    it "should use the singular in the comment line" do
      expect(email.subject).to eq("1 new comment on planning applications near #{@alert.address}")
    end

    it "should have the unsubscribe header" do
      expect(email.header["List-Unsubscribe"].to_s).to eq("<https://dev.planningalerts.org.au/alerts/abcdef/unsubscribe>")
    end
  end

  describe "when sending a planning alert with two new comments" do
    let(:email) { AlertNotifier.alert("default", @alert, [], [@c1, @c2])}

    it "should use the plural in the comment line" do
      expect(email.subject).to eq("2 new comments on planning applications near #{@alert.address}")
    end

    it "should nicely format (in text) a list of multiple planning applications" do
      expect(email.text_part.body).to include Rails.root.join("spec/mailers/regression/alert_notifier/email3.txt").read
    end

    it "should nicely format (in HTML) a list of multiple planning applications" do
      expect(email.html_part.body.to_s).to eq(Rails.root.join("spec/mailers/regression/alert_notifier/email3.html").read)
    end
  end

  describe "when sending an email alert with more than 10 comments in the application" do
    let(:email) { AlertNotifier.alert("default", @alert, [], [@c1, @c2])}

    expect()
  end

  describe "when send a planning alert with one new comment and two new planning applications" do
    let(:email) { AlertNotifier.alert("default", @alert, [@a1, @a2], [@c1])}

    it "should tell you about both in the comment line" do
      expect(email.subject).to eq("1 new comment and 2 new planning applications near #{@alert.address}")
    end

    it "should nicely format (in text) a list of multiple planning applications" do
      expect(email.text_part.body).to include Rails.root.join("spec/mailers/regression/alert_notifier/email2.txt").read
    end

    it "should nicely format (in HTML) a list of multiple planning applications" do
      expect(email.html_part.body.to_s).to eq(Rails.root.join("spec/mailers/regression/alert_notifier/email2.html").read)
    end
  end

  describe "when sending a planning alert with one new planning application" do
    before :each do
      @email = AlertNotifier.alert("default", @alert, [@a1])
    end

    it "should use the singular (application) in the subject line" do
      expect(@email.subject).to eq("1 new planning application near #{@alert.address}")
    end
  end

  describe "when sending a planning alert with two new planning applications" do
    context "and the theme is Default" do
      before :each do
        @email = AlertNotifier.alert("default", @alert, [@a1, @a2])
      end

      it "should be sent to the user's email address" do
        expect(@email.to).to eq([@alert.email])
      end

      it "should be from the main planningalerts email address" do
        expect(@email.from).to eq(["contact@planningalerts.org.au"])
        #@email.from_addrs.first.name.should == "PlanningAlerts.org.au"
      end

      it "should have a sensible subject line" do
        expect(@email.subject).to eq("2 new planning applications near #{@alert.address}")
      end

      it "should be a multipart email" do
        expect(@email.body.parts.length).to eq(2)
      end

      context "Text email" do
        it "should nicely format a list of multiple planning applications" do
          expect(@email.text_part.body).to include Rails.root.join("spec/mailers/regression/alert_notifier/email1.txt").read
        end
      end

      context "HTML emails" do
        before :each do
          @html_body = @email.html_part.body.to_s
        end

        it 'should contain links to the applications' do
          expect(@html_body).to have_link("Foo Street, Bar", href: "https://dev.planningalerts.org.au/applications/1?utm_campaign=view-application&utm_medium=email&utm_source=alerts")
          expect(@html_body).to have_link("Bar Street, Foo", href: "https://dev.planningalerts.org.au/applications/2?utm_campaign=view-application&utm_medium=email&utm_source=alerts")
        end

        it 'should contain application descriptions' do
          expect(@html_body).to have_content "Knock something down"
          expect(@html_body).to have_content "Put something up"
        end

        it "should have a specific body" do
          expect(@html_body).to eq(Rails.root.join("spec/mailers/regression/alert_notifier/email1.html").read)
        end
      end
    end

    context "and the theme is NSW" do
      before :each do
        @email = AlertNotifier.alert("nsw", @alert, [@a1, @a2])
      end

      # TODO This is just a temporary address
      it "should be from the nsw theme’s email address" do
        expect(@email.from).to eq(["contact@nsw.127.0.0.1.xip.io"])
      end

      context "Text email" do
        it "should nicely format a list of multiple planning applications" do
          expect(@email.text_part.body).to include Rails.root.join("spec/mailers/regression/alert_notifier/email4.txt").read
        end
      end

      context "HTML email" do
        before :each do
          @html_body = @email.html_part.body.to_s
        end

        it 'should contain links to the applications' do
          expect(@html_body).to have_link("Foo Street, Bar", href: "http://nsw.127.0.0.1.xip.io:3000/applications/1?utm_campaign=view-application&utm_medium=email&utm_source=alerts")
          expect(@html_body).to have_link("Bar Street, Foo", href: "http://nsw.127.0.0.1.xip.io:3000/applications/2?utm_campaign=view-application&utm_medium=email&utm_source=alerts")
        end

        it "should have a specific body" do
          expect(@html_body).to eq(Rails.root.join("spec/mailers/regression/alert_notifier/email4.html").read)
        end
      end
    end
  end

  describe ".new_signup_attempt_notice" do
    it "puts the address in the subject" do
      alert = build(:alert, address: "123 Lovely St, La La")
      email = AlertNotifier.new_signup_attempt_notice(alert)

      expect(email).to have_subject "Your subscription for 123 Lovely St, La La"
    end

    it "tells the user that we’ve recieved a new signup attempt" do
      alert = build(:alert, address: "123 Lovely St, La La")
      email = AlertNotifier.new_signup_attempt_notice(alert)

      expect(email.html_part.body.to_s).to have_content "We just received a new request to send PlanningAlerts for 123 Lovely St, La La to your email address."
      expect(email.text_part.body.to_s).to have_content "We just received a new request to send PlanningAlerts for 123 Lovely St, La La to your email address."
    end
  end
end
