ActiveAdmin.register User do
  actions :index, :show

  index :download_links => false do
    column :email
    column :name
    column :organisation
    column :api_key
    column :bulk_api
    column :admin
    default_actions
  end
end
