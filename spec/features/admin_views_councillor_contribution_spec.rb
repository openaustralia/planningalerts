require "spec_helper"

feature "Admin views councillor contributions" do
  let(:authority) { create(:authority, full_name: "Casey City Council") }
  let(:contributor) { create(:contributor, name: "Felix Chaung", email: "example@gmail.com") }

  around :each do |example|
    Timecop.freeze(Time.local(2017, 8, 1))
    example.run
    Timecop.return
  end

  before :each do
    councillor_contribution = create(
      :councillor_contribution,
      contributor: contributor,
      authority: authority,
      created_at: Time.current
    )

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
    expect(page).to have_content "Felix Chaung #{Time.current.strftime('%B %d, %Y %H:%M')} Casey City Council No"
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

    expect(page).to have_xpath("//input[@value='Mark as not reviewed']")
  end

  it "shows the reviewed status on the index page" do
    click_link "View"

    click_button("Mark as reviewed")

    first(:link, "Councillor Contributions").click

    expect(page).to have_content "Felix Chaung #{Time.current.strftime('%B %d, %Y %H:%M')} Casey City Council Yes"
  end
end
