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
    default_actions
  end

  filter :text
  filter :email
  filter :name
end
