ActiveAdmin.register Report do
  actions :index, :show, :destroy

  filter :name
  filter :email
  filter :details

  index do
    column :created_at
    column :name
    column :email
    column :details do |report|
      truncate(report.details)
    end
    column :comment
    actions
  end
end
