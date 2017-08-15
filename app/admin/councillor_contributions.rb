ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column :contributor
    column :created_at
    column :authority

    actions
  end

  show title: :created_at do
    attributes_table do
      row :contributor
      row :id
    end

    h3 "Suggested Councillor"
      table_for resource.suggested_councillors, class: "index_table" do
        column :created_at
        column :authority
        column :name
        column :email
    end
  end
end
