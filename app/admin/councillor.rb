ActiveAdmin.register Councillor do
  actions :all

  index do
    column :authority
    column :name
    column :email
    column :party
    actions
  end

  remove_filter :comments

  permit_params :name, :image_url, :party, :email, :authority_id
end
