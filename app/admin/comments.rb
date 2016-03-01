ActiveAdmin.register Comment do
  menu label: "Comments"
  actions :all, except: [:destroy, :new, :create]

  scope :visible, default: true
  scope :all

  index title: "Comments" do
    column :text, sortable: false do |comment|
      truncate(comment.text)
    end
    column :email
    column :name
    column :application
    actions
  end

  filter :text
  filter :email
  filter :name
  filter :hidden
  filter :application_id

  form do |f|
    inputs "Text" do
      input :text
    end
    inputs "Person details" do
      input :email
      input :name
      input :address
    end
    inputs "Comment Properties" do
      input :confirmed
      input :hidden
    end
    actions
  end

  permit_params :text, :email, :name, :confirmed, :address, :hidden
end
