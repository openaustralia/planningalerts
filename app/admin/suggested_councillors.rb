ActiveAdmin.register SuggestedCouncillor do
  actions :index
  index do
    column :authority
    column :name
    column :email
  end
end
