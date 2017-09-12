ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column(:contributor) { |contribution| contribution.attribution }
    column :created_at
    column :authority
    column :reviewed

    actions
  end

  show title: proc {|resource| "Councillor Contribution for #{resource.authority.full_name}, #{resource.created_at.strftime('%B %d, %Y')}"} do
    attributes_table do
      row(:contributor) { |contribution| contribution.attribution(with_email: true) }
    end

    h3 "Suggested Councillors"
    table_for resource.suggested_councillors, class: "index_table" do
      column :name
      column :email
    end
  end

  action_item :download,:only => [:show] do
    link_to "Download the suggested councillors CSV", authority_councillor_contribution_path(resource.authority, resource.id, format: :csv)
  end
end
