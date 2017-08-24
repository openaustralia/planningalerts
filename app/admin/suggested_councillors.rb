ActiveAdmin.register SuggestedCouncillor do
 belongs_to :councillor_contribution

 filter :councillor_contribution, :collection => proc { @councillor_contribution.suggested_councillors}
  csv do
    column :name
    column :email
  end
end
