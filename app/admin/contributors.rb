ActiveAdmin.register Contributor do
    actions :index, :show

    index do
      column :name
      column :email
      column :id

      actions
    end
end
