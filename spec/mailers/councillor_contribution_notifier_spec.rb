require "spec_helper"

describe CouncillorContributionNotifier do
  describe "notice of councillor contribution for admin" do
    let(:authority) { create(:authority, full_name: "Casey City Council") }
    let(:councillor_contribution) { create(:councillor_contribution, authority: authority, id: 1) }
    let(:mailer) { CouncillorContributionNotifier.notify(councillor_contribution) }

    it "should come from the moderator's email address" do
      expect(mailer.from).to eq(["moderator@planningalerts.org.au"])
    end

    it "should go to the moderator email address" do
      expect(mailer.to).to eq(["moderator@planningalerts.org.au"])
    end

    it "should tell the moderator what the email is about" do
      expect(mailer.subject).to eq("PlanningAlerts: New councillor contribution")
    end

    it "should contain the authority name of the councillor contribution" do
      expect(mailer.body.to_s).to include("Casey City Council")
    end

    it "should contain the link to the admin show page of the councillor contribition" do
      expect(mailer.body.to_s).to have_link("review the contribution on its admin page", href: "http://dev.planningalerts.org.au/admin/councillor_contributions/1")
    end
  end
end
