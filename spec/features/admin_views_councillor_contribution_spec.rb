require "spec_helper"

feature "Admin views a suggested councillor" do
  before do
    create(
      :suggested_councillor,
      name: "Mila Gilic",
      email: "mgilic@casey.vic.gov.au",
      authority: create(:authority, full_name: "Casey City Council")
    )
  end

  it "successfully" do
    sign_in_as_admin

    click_link "Suggested Councillors"

    expect(page).to have_content "Casey City Council Mila Gilic mgilic@casey.vic.gov.au"
  end
end

feature "Admin views councillor contributions" do
  before :each do
      Timecop.freeze(Time.local(2017, 8, 1))

      authority = create(:authority, full_name: "Casey City Council")
      contributor = create(:contributor, name: "Felix Chaung", email: "example@gmail.com")
      councillor_contribution = create(:councillor_contribution, contributor: contributor)
      creation_time = "2017-08-01 00:00:00 -0400"

      create(
        :suggested_councillor,
        name: "Mila Gilic",
        email: "mgilic@casey.vic.gov.au",
        authority: authority,
        councillor_contribution: councillor_contribution,
        created_at: creation_time
      )
      create(
        :suggested_councillor,
        name: "Susan Serey",
        email: "sserey@.vic.gov.au",
        authority: authority,
        councillor_contribution: councillor_contribution,
        created_at: creation_time
      )
      create(
        :suggested_councillor,
        name: "Rosalie Crestani",
        email: "rcrestani@.vic.gov.au",
        authority: authority,
        councillor_contribution: councillor_contribution,
        created_at: creation_time
      )
  end

  after :each do
    Timecop.return
  end

  it "successfully" do
    sign_in_as_admin

    click_link "Councillor Contributions"

    expect(page).to have_content "Felix Chaung August 01, 2017 04:00"
  end
end
