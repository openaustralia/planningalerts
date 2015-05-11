ActiveAdmin.register Report do
  actions :all, :except => [:destroy, :new, :create] 

  filter :name
  filter :email
  filter :details

  index do
    column :name
    column :email
    column :details do |report|
      truncate(report.details)
    end
    column :comment
    actions
  end
end
