ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column "Councillor Contribution id", :id
    column :authority
    actions
  end

  show title: :created_at do
    attributes_table do
      row :id
      row :authority
    end

end
