ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column :contributor
    column :created_at
    column :authority

    actions
  end

  show title: proc {|resource| "Councillor Contribution for #{resource.authority_name}, #{resource.created_at.strftime('%B %d, %Y')}"} do
    attributes_table do
      row("Contributor") do |r|
        if resource.contributor.present?
          "#{r.contributor.name} ( #{ r.contributor.email } )"
        else
          "Anonymous"
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
