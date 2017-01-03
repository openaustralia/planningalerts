ActiveAdmin.register Councillor do
  actions :all

  index do
    column :authority
    column :name
    column :current
    column :email
    column :party
    column(:number_of_comments) { |c| c.comments.count }
    column(:number_of_replies) { |c| c.replies.count }
    actions
  end

  remove_filter :comments
  remove_filter :replies

  permit_params :name, :image_url, :party, :email, :authority_id
end
