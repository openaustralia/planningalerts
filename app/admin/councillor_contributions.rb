ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column "Councillor Contribution id", :id
    column :created_at
    column :authority
    actions
  end

  show title: :created_at do
    attributes_table do
      row :id
      row :authority
    end

    h3 "Suggested Councillor"
      table_for resource.suggested_councillors, class: "index_table" do
        column :name
        column :email
    end
  end
end
