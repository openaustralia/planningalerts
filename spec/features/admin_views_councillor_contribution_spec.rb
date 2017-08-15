require "spec_helper"

feature "Admin views councillor contributions" do
  before :each do
      Timecop.freeze(Time.local(2017, 8, 1))

      authority = create(:authority, full_name: "Casey City Council")
      contributor = create(:contributor, name: "Felix Chaung", email: "example@gmail.com")
      councillor_contribution = create(:councillor_contribution, contributor: contributor, authority: authority)
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
  end

  after :each do
    Timecop.return
  end

  it "successfully on the index page" do
    sign_in_as_admin

    click_link "Councillor Contributions"

    expect(page).to have_content "Felix Chaung #{Time.current.strftime('%B %d, %Y %H:%M')} Casey City Council"
  end

  it "successfully with suggested councillors on the show page" do
    sign_in_as_admin

    click_link "Councillor Contributions"

    click_link "View"

    expect(page).to have_content "Contributor Felix Chaung"
    expect(page).to have_content "Authority Casey City Council"
    expect(page).to have_content "Mila Gilic mgilic@casey.vic.gov.au"
    expect(page).to have_content "Susan Serey sserey@casey.vic.gov.au"
    expect(page).to have_content "Rosalie Crestani rcrestani@casey.vic.gov.au"
  end
end
