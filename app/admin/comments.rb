ActiveAdmin.register Comment do
  menu label: "Comments"
  actions :all, except: [:destroy, :new, :create]

  scope :visible, default: true
  scope(:hidden) { |s| s.where(hidden: true) }
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

  filter :application_id
  filter :email
  filter :name
  filter :text

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

  action_item :load_reply, only: :show do
    if resource.to_councillor? && resource.writeit_message_id
      button_to("Check WriteIt for replies", load_reply_admin_comment_path)
    end
  end

  member_action :load_reply, method: :post do
    if resource.create_reply_from_writeit!
      redirect_to({action: :show}, notice: "Reply loaded")
    else
      redirect_to({action: :show}, notice: "No reply loaded")
    end
  end

  permit_params :text, :email, :name, :confirmed, :address, :hidden
end
