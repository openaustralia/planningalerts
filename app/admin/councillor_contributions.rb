ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column :contributor
    column :created_at
    column :authority

    actions
  end

  show title: :created_at do

    panel "Councillor Contribution Details" do
      render partial: "details", locals: {contributor: resource.contributor, authority: resource.authority}
    end

    h3 "Suggested Councillors"
    table_for resource.suggested_councillors, class: "index_table" do
      column :name
      column :email
    end
  end
end
