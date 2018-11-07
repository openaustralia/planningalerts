# frozen_string_literal: true

require "spec_helper"

feature "Admin views councillor contributions" do
  let(:authority) { create(:authority, full_name: "Casey City Council") }
  let(:contributor) { create(:contributor, name: "Felix Chaung", email: "example@gmail.com") }
  let(:councillor_contribution) do
    create(
      :councillor_contribution,
      contributor: contributor,
      authority: authority,
      created_at: Time.utc(2017, 8, 1, 11, 34, 5)
    )
  end

  before :each do
    create(
      :suggested_councillor,
      name: "Mila Gilic",
      email: "mgilic@casey.vic.gov.au",
      councillor_contribution: councillor_contribution
    )
    create(
      :suggested_councillor,
      name: "Susan Serey",
      email: "sserey@casey.vic.gov.au",
      councillor_contribution: councillor_contribution
    )
    create(
      :suggested_councillor,
      name: "Rosalie Crestani",
      email: "rcrestani@casey.vic.gov.au",
      councillor_contribution: councillor_contribution
    )

    sign_in_as_admin

    click_link "Councillor Contributions"
  end

  it "successfully on the index page" do
    expect(page).to have_content "Felix Chaung August 01, 2017 11:34 Casey City Council No No"
  end

  it "successfully with suggested councillors on the show page with contributor information" do
    click_link "View"

    expect(page).to have_content "Felix Chaung"
    expect(page).to have_content "example@gmail.com"
    expect(page).to have_content "Casey City Council"
    expect(page).to have_content "Mila Gilic mgilic@casey.vic.gov.au"
    expect(page).to have_content "Susan Serey sserey@casey.vic.gov.au"
    expect(page).to have_content "Rosalie Crestani rcrestani@casey.vic.gov.au"
  end

  it "and marks one as reviewed" do
    click_link "View"

    click_button("Mark as reviewed")

    first(:link, "Councillor Contributions").click

    expect(page).to have_content "Felix Chaung August 01, 2017 11:34 Casey City Council Yes No"
  end

  context "when one has been reviewed" do
    before { councillor_contribution.update(reviewed: true) }

    it "marks it as 'not reviewd'" do
      click_link "View"

      click_button("Mark as not reviewed")

      first(:link, "Councillor Contributions").click

      expect(page).to have_content "Felix Chaung August 01, 2017 11:34 Casey City Council No No"
    end

    it "and marks it as accepted" do
      click_link "View"

      click_button("Mark as accepted")

      first(:link, "Councillor Contributions").click

      expect(page).to have_content "Felix Chaung August 01, 2017 11:34 Casey City Council Yes Yes"
    end

    context "and accepted" do
      before { councillor_contribution.update(accepted: true) }

      it "and marks one as not accepted" do
        click_link "View"

        click_button("Mark as not accepted")

        first(:link, "Councillor Contributions").click

        expect(page).to have_content "Felix Chaung August 01, 2017 11:34 Casey City Council Yes No"
      end

      it "marking it as not reviewed also marks it not accepted" do
        click_link "View"

        click_button("Mark as not reviewed")

        first(:link, "Councillor Contributions").click

        expect(page).to have_content "Felix Chaung August 01, 2017 11:34 Casey City Council No No"
      end
    end
  end
end
