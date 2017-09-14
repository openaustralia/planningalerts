require "spec_helper"

feature "Admin views councillor contributions" do
  before :each do
      Timecop.freeze(Time.local(2017, 8, 1))

      authority = create(:authority, full_name: "Casey City Council")
      contributor = create(:contributor, name: "Felix Chaung", email: "example@gmail.com")
      councillor_contribution = create(:councillor_contribution, contributor: contributor, authority: authority, id: 1)
      creation_time = Time.current

      create(
        :suggested_councillor,
        name: "Mila Gilic",
        email: "mgilic@casey.vic.gov.au",
        councillor_contribution: councillor_contribution,
        created_at: creation_time
      )
      create(
        :suggested_councillor,
        name: "Susan Serey",
        email: "sserey@casey.vic.gov.au",
        councillor_contribution: councillor_contribution,
        created_at: creation_time
      )
      create(
        :suggested_councillor,
        name: "Rosalie Crestani",
        email: "rcrestani@casey.vic.gov.au",
        councillor_contribution: councillor_contribution,
        created_at: creation_time
      )

      sign_in_as_admin

      click_link "Councillor Contributions"
  end

  after :each do
    Timecop.return
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
    expect(page).to have_text "Reviewed"
    find(:css, "#councillor_contribution_reviewed[value='1']").set(false)
  end

  it "can change the status of reviewed when admin click the checkbox in #view page" do
    click_link "View"

    check("Reviewed")

    click_button("Update Councillor contribution")

    expect(page). to have_content("Councillor contribution was successfully updated.")
  end

  it "shows the reviewed status on the index page" do
    click_link "View"

    check("Reviewed")

    click_button("Update Councillor contribution")

    first(:link, "Councillor Contributions").click

    expect(page).to have_content "Felix Chaung #{Time.current.strftime('%B %d, %Y %H:%M')} Casey City Council Yes"
  end
end
