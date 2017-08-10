ActiveAdmin.register SuggestedCouncillor do
  actions :index
  index do
    column :authority
    column :name
    column :email
    column :councillor_contribution_id
  end
end
