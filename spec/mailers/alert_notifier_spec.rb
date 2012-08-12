require 'spec_helper'

describe AlertNotifier do
  before :each do
    @alert = Alert.create!(:email => "matthew@openaustralia.org", :address => "24 Bruce Rd, Glenbrook NSW 2773",
      :lat => 1.0, :lng => 2.0, :radius_meters => 800)
    @alert.stub!(:confirm_id).and_return("abcdef")
    @original_emails_sent = Stat.emails_sent
    @original_applications_sent = Stat.applications_sent
    @a1 = mock_model(Application, :address => "Foo Street, Bar", :council_reference => "a1", :description => "Knock something down", :id => 1)
    @a2 = mock_model(Application, :address => "Bar Street, Foo", :council_reference => "a2", :description => "Put something up", :id => 2)
  end

  describe "when sending a planning alert with one new comment" do
    let(:email) { AlertNotifier.alert(@alert, [], [@c1])}

    it "should use the singular in the comment line" do
      email.subject.should == "1 new comment on planning applications near #{@alert.address}"
    end
  end

  describe "when sending a planning alert with two new comments" do
    let(:email) { AlertNotifier.alert(@alert, [], [@c1, @c2])}

    it "should use the plural in the comment line" do
      email.subject.should == "2 new comments on planning applications near #{@alert.address}"
    end
  end

  describe "when send a planning alert with one new comment and two new planning applications" do
    let(:email) { AlertNotifier.alert(@alert, [@a1, @a2], [@c1])}

    it "should tell you about both in the comment line" do
      email.subject.should == "1 new comment and 2 new planning applications near #{@alert.address}"
    end
  end

  describe "when sending a planning alert with one new planning application" do
    before :each do
      @email = AlertNotifier.alert(@alert, [@a1])
    end

    it "should use the singular (application) in the subject line" do
      @email.subject.should == "1 new planning application near #{@alert.address}"
    end
  end
  
  describe "when sending a planning alert with two new planning applications" do
    before :each do
      @email = AlertNotifier.alert(@alert, [@a1, @a2])
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
    
    it "should update the statistics" do
      Stat.emails_sent.should == @original_emails_sent + 1
      Stat.applications_sent.should == @original_applications_sent + 2
    end
    
    it "should update last_sent to the current time" do
      (Time.now - @alert.last_sent).abs.should < 1
    end
    
    it "should be a multipart email" do
      @email.body.parts.length.should eq(2)
    end

    context "Text email" do
      it "should nicely format a list of multiple planning applications" do
        get_message_part(@email, /plain/).should == <<-EOF
The following new planning applications have been found within 800 m of 24 Bruce Rd, Glenbrook NSW 2773:

Foo Street, Bar

Knock something down

http://dev.planningalerts.org.au/applications/1?utm_medium=email&utm_source=alerts

-----------------------------

Bar Street, Foo

Put something up

http://dev.planningalerts.org.au/applications/2?utm_medium=email&utm_source=alerts

============================================================

PlanningAlerts.org.au is a free service run by the charity OpenAustralia Foundation.
This service depends on donations from people like you for its survival.
If you use this service please consider donating: http://www.openaustraliafoundation.org.au/donate/?utm_medium=email&utm_source=alerts

To change the size of the area covered by the alerts: http://dev.planningalerts.org.au/alerts/abcdef/area

To stop receiving these emails: http://dev.planningalerts.org.au/alerts/abcdef/unsubscribe
        EOF
      end
    end

    context "HTML emails" do
      before :each do
        @html_body = get_message_part(@email, /html/)
      end

      it 'should contain links to the applications' do
        contains_link(@html_body, "http://dev.planningalerts.org.au/applications/1?utm_medium=email&utm_source=alerts", "Foo Street, Bar")
        contains_link(@html_body, "http://dev.planningalerts.org.au/applications/2?utm_medium=email&utm_source=alerts", "Bar Street, Foo")
      end

      it 'should contain application descriptions' do
        @html_body.should contain "Knock something down"
        @html_body.should contain "Put something up"
      end

      it "should have a specific layout" do
        @html_body.should == <<-EOF
<!DOCTYPE html>
<html>
<body style='font-family:sans-serif;'>
<div style='background: #878787; padding: 5px 0 5px 10px; margin-bottom:5px'>
<a href='http://www.planningalerts.org.au/' style='color: white; font-weight:bold; font-size: 20px; text-decoration:none;'>
PlanningAlerts
</a>
</div>
<div style='margin: 6px 11px 25px; padding: 15px; background: #fcfbbd; -moz-border-radius: 10px; -khtml-border-radius: 10px; -webkit-border-radius: 10px;'>
The following new planning applications have been found within 800 m of
<strong>24 Bruce Rd, Glenbrook NSW 2773</strong>
</div>
<table style='padding-left: 15px; padding-bottom: 15px;'>
<tr>
<td colspan='2' style='padding-bottom: 5px;'>
<a href="http://dev.planningalerts.org.au/applications/1?utm_medium=email&amp;utm_source=alerts" style="font-size: 18px; font-weight: bold; color: #f2630c;">Foo Street, Bar</a>
</td>
</tr>
<tr>
<td style='padding: 5px; width: 155px;'>
<img height='150' src='http://maps.googleapis.com/maps/api/staticmap?zoom=14&amp;size=150x150&amp;maptype=roadmap&amp;markers=color:red%7CFoo%20Street%2C%20Bar&amp;sensor=false' width='150'>
</td>
<td style='padding: 5px;'>
<img height='150' src='http://maps.googleapis.com/maps/api/streetview?size=150x150&amp;location=Foo%20Street%2C%20Bar&amp;fov=60&amp;sensor=false' width='150'>
</td>
</tr>
<tr>
<td colspan='2' style='vertical-align: top;'>
Knock something down
</td>
</tr>
</table>
<table style='padding-left: 15px; padding-bottom: 15px;'>
<tr>
<td colspan='2' style='padding-bottom: 5px;'>
<a href="http://dev.planningalerts.org.au/applications/2?utm_medium=email&amp;utm_source=alerts" style="font-size: 18px; font-weight: bold; color: #f2630c;">Bar Street, Foo</a>
</td>
</tr>
<tr>
<td style='padding: 5px; width: 155px;'>
<img height='150' src='http://maps.googleapis.com/maps/api/staticmap?zoom=14&amp;size=150x150&amp;maptype=roadmap&amp;markers=color:red%7CBar%20Street%2C%20Foo&amp;sensor=false' width='150'>
</td>
<td style='padding: 5px;'>
<img height='150' src='http://maps.googleapis.com/maps/api/streetview?size=150x150&amp;location=Bar%20Street%2C%20Foo&amp;fov=60&amp;sensor=false' width='150'>
</td>
</tr>
<tr>
<td colspan='2' style='vertical-align: top;'>
Put something up
</td>
</tr>
</table>

<div style='border-top: solid 3px #F2630C;'>
<div style='padding-left: 15px; padding-top: 5px;'>
<p>
<a href='http://www.planningalerts.org.au/?utm_medium=email&amp;utm_source=alerts' style='color: #f2630c;'>PlanningAlerts</a>
is a free service run by the charity <a href="http://openaustraliafoundation.org.au/?utm_medium=email&utm_source=alerts" style="color: #f2630c;">OpenAustralia Foundation</a>.
</p>
<p>
<strong>This service depends on donations from people like you for its survival.</strong>
If you use this service <a href="http://www.openaustraliafoundation.org.au/donate/?utm_medium=email&utm_source=alerts" style="color: #f2630c;">please consider donating</a>.
</p>
<p>
You can
<a href="http://dev.planningalerts.org.au/alerts/abcdef/area" style="color: #f2630c;">change the size</a>
of the area covered by this alert or
<a href="http://dev.planningalerts.org.au/alerts/abcdef/unsubscribe" style="color: #f2630c;">unsubscribe</a>
and stop receiving these emails.
</p>
</div>
</div>

</body>
</html>
        EOF
      end
    end

    def get_message_part (mail, content_type)
      mail.body.parts.find { |p| p.content_type.match content_type }.body.raw_source
    end

    def contains_link(html, url, text)
      html.should match /<a href="#{url.gsub(/\//, '\/').gsub(/&/, '&amp;').gsub(/\?/, '\?')}"[^>]*>#{text}<\/a>/
    end
  end
end
