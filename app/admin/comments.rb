# Workaround for annoying bug in active_admin. See https://github.com/gregbell/active_admin/issues/64
ActiveAdmin.register Comment, :as => "ApplicationComment" do
  menu :label => "Comments"
  actions :all, :except => [:destroy, :new, :create]

  scope :visible, :default => true
  scope :all

  index :title => "Comments" do
    column :text, :sortable => false do |comment|
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
end
