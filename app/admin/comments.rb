# Workaround for annoying bug in active_admin. See https://github.com/gregbell/active_admin/issues/64
ActiveAdmin.register Comment, :as => "ApplicationComment" do
  menu :label => "Comments"
  actions :all, :except => [:destroy, :new, :create]

  scope :visible, :default => true
  scope :all

  index :title => :comments do
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
    f.inputs "Text" do
      f.input :text
    end
    f.inputs "Person details" do
      f.input :email
      f.input :name
      f.input :address
    end
    f.inputs "Comment Properties" do
      f.input :confirmed
      f.input :hidden
    end
    f.buttons
  end

end
