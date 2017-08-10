ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column "Councillor Contribution id", :id
    column :authority
    actions
  end

end
