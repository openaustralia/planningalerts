ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column :contributor
    column :created_at
    column :authority

    actions
  end

  show title: proc {|resource| "Councillor Contribution for #{resource.authority_name}, #{resource.created_at.strftime('%B %d, %Y')}"} do
    if resource.contributor.present?
      panel "Councillor Contribution Details" do
      render partial: "details", locals: {contributor: resource.contributor}
      end
    else
      panel "Councillor Contribution Details" do
        table_for resource do
          column "Contributor" do
            "Anonymous Contributor"
          end
        end
      end
    end

    h3 "Suggested Councillors"
    table_for resource.suggested_councillors, class: "index_table" do
      column :name
      column :email
    end
  end
end
