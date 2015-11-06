ActiveAdmin.register Councillor do
  actions :all

  remove_filter :comments

  permit_params :name, :image_url, :party, :email
end
