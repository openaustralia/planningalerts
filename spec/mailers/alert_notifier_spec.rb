require 'spec_helper'

describe AlertNotifier do
  before :each do
    @alert = Factory.create(:alert, :email => "matthew@openaustralia.org", :address => "24 Bruce Rd, Glenbrook NSW 2773",
      :lat => 1.0, :lng => 2.0, :radius_meters => 800)
    @alert.stub!(:confirm_id).and_return("abcdef")
    @original_emails_sent = Stat.emails_sent
    @original_applications_sent = Stat.applications_sent
    location1 = mock("Location", :lat => 0.1, :lng => 0.2)
    @a1 = mock_model(Application, :address => "Foo Street, Bar", :council_reference => "a1", :description => "Knock something down", :id => 1,
        :lat => location1.lat, :lng => location1.lng, :location => location1)
    location2 = mock("Location", :lat => 0.3, :lng => 0.4)
    @a2 = mock_model(Application, :address => "Bar Street, Foo", :council_reference => "a2", :description => "Put something up", :id => 2,
        :lat => location2.lat, :lng => location2.lng, :location => location2)
    @a3 = mock_model(Application, :address => "2 Foo Parade, Glenbrook NSW 2773", :id => 3)
    @c1 = mock_model(Comment, :text => "I think this is a great idea", :name => "Matthew Landauer", :application => @a3, :id => 1)
    @c2 = mock_model(Comment, :name => "Jack Smith", :application => @a3, :id => 2, :text => <<-EOF
Carles typewriter officia, cillum ethical elit swag. Consequat cillum yr wes anderson. 3 wolf moon blog iphone, pickled irure skateboard mcsweeney's seitan keffiyeh wayfarers. Jean shorts sriracha sed laborum. Next level forage flexitarian id. Mixtape sriracha sartorial beard ut, salvia adipisicing veniam wayfarers bushwick ullamco 8-bit incididunt. Scenester excepteur dreamcatcher, truffaut organic placeat esse post-ironic carles cupidatat nihil butcher sartorial fanny pack lo-fi.

Cillum ethnic single-origin coffee labore, sriracha fixie jean shorts freegan. Odd future aesthetic tempor, mustache bespoke gastropub dolore polaroid salvia helvetica. Kogi chambray cardigan sunt single-origin coffee. Cardigan echo park master cleanse craft beer. Carles sunt selvage, beard gastropub artisan chillwave odio VHS street art you probably haven't heard of them gentrify mixtape aesthetic. Salvia chambray anim occupy echo park est. Pork belly sint post-ironic ennui, PBR vero culpa readymade cardigan laboris.
    EOF
    )
  end

  describe "when sending a planning alert with one new comment" do
    let(:email) { AlertNotifier.alert("default", @alert, [], [@c1])}

    it "should use the singular in the comment line" do
      email.subject.should == "1 new comment on planning applications near #{@alert.address}"
    end

    it "should have the unsubscribe header" do
      email.header["List-Unsubscribe"].to_s.should == "<https://dev.planningalerts.org.au/alerts/abcdef/unsubscribe>"
    end
  end

  describe "when sending a planning alert with two new comments" do
    let(:email) { AlertNotifier.alert("default", @alert, [], [@c1, @c2])}

    it "should use the plural in the comment line" do
      email.subject.should == "2 new comments on planning applications near #{@alert.address}"
    end

    it "should nicely format (in text) a list of multiple planning applications" do
      get_message_part(email, /plain/).should include Rails.root.join("spec/mailers/regression/alert_notifier/email3.txt").read
    end

    it "should nicely format (in HTML) a list of multiple planning applications" do
      get_message_part(email, /html/).should == Rails.root.join("spec/mailers/regression/alert_notifier/email3.html").read
    end
  end

  describe "when send a planning alert with one new comment and two new planning applications" do
    let(:email) { AlertNotifier.alert("default", @alert, [@a1, @a2], [@c1])}

    it "should tell you about both in the comment line" do
      email.subject.should == "1 new comment and 2 new planning applications near #{@alert.address}"
    end

    it "should nicely format (in text) a list of multiple planning applications" do
      get_message_part(email, /plain/).should include Rails.root.join("spec/mailers/regression/alert_notifier/email2.txt").read
    end

    it "should nicely format (in HTML) a list of multiple planning applications" do
      get_message_part(email, /html/).should == Rails.root.join("spec/mailers/regression/alert_notifier/email2.html").read
    end
  end

  describe "when sending a planning alert with one new planning application" do
    before :each do
      @email = AlertNotifier.alert("default", @alert, [@a1])
    end

    it "should use the singular (application) in the subject line" do
      @email.subject.should == "1 new planning application near #{@alert.address}"
    end
  end

  describe "when sending a planning alert with two new planning applications" do
    before :each do
      @email = AlertNotifier.alert("default", @alert, [@a1, @a2])
    end

    it "should be sent to the user's email address" do
      @email.to.should == [@alert.email]
    end

    it "should be from the main planningalerts email address" do
      @email.from.should == ["contact@planningalerts.org.au"]
      #@email.from_addrs.first.name.should == "PlanningAlerts.org.au"
    end

    it "should have a sensible subject line" do
      @email.subject.should == "2 new planning applications near #{@alert.address}"
    end

    it "should be a multipart email" do
      @email.body.parts.length.should eq(2)
    end

    context "Text email" do
      it "should nicely format a list of multiple planning applications" do
        get_message_part(@email, /plain/).should include Rails.root.join("spec/mailers/regression/alert_notifier/email1.txt").read
      end
    end

    describe "when sending a planning alert with two new planning applications in the nsw theme" do
      before :each do
        @email = AlertNotifier.alert("nsw", @alert, [@a1, @a2])
      end

      # TODO This is just a temporary address
      it "should be from the main themes website email address" do
        @email.from.should == ["contact@nsw.127.0.0.1.xip.io"]
      end

      context "Text email" do
        it "should nicely format a list of multiple planning applications" do
          get_message_part(@email, /plain/).should include Rails.root.join("spec/mailers/regression/alert_notifier/email4.txt").read
        end
      end

      context "HTML email" do
        it "should have a specific body" do
          get_message_part(@email, /html/).should == Rails.root.join("spec/mailers/regression/alert_notifier/email4.html").read
        end
      end
    end

    context "HTML emails" do
      before :each do
        @html_body = get_message_part(@email, /html/)
      end

      it 'should contain links to the applications' do
        @html_body.should have_link("Foo Street, Bar", href: "https://dev.planningalerts.org.au/applications/1?utm_medium=email&utm_source=alerts")
        @html_body.should have_link("Bar Street, Foo", href: "https://dev.planningalerts.org.au/applications/2?utm_medium=email&utm_source=alerts")
      end

      it 'should contain application descriptions' do
        @html_body.should have_content "Knock something down"
        @html_body.should have_content "Put something up"
      end

      it "should have a specific body" do
        @html_body.should == Rails.root.join("spec/mailers/regression/alert_notifier/email1.html").read
      end
    end
  end

  def get_message_part (mail, content_type)
    part = mail.body.parts.find { |p| p.content_type.match content_type }
    part.body.raw_source
  end
end
