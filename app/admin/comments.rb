ActiveAdmin.register Comment do
  menu label: "Comments"
  actions :all, except: %i[destroy new create]

  scope :visible, default: true
  scope("Visible, sent to councillor") { |s| s.visible.to_councillor }
  scope(:hidden) { |s| s.where(hidden: true) }
  scope :all

  index title: "Comments" do
    column :text, sortable: false do |comment|
      truncate(comment.text)
    end
    column :email
    column :name
    column :application
    column :councillor
    actions
  end

  filter :application_id
  filter :email
  filter :name
  filter :text
  filter :councillor

  show title: proc { |resource| "Comment by #{resource.name}#{' (unconfirmed)' unless resource.confirmed?}" }

  form do |_f|
    inputs "Text" do
      input :text
    end
    inputs "Person details" do
      input :email
      input :name
      input :address
    end
    inputs "Moderate comment" do
      input :hidden
    end
    actions
  end

  action_item :load_replies, only: :show do
    if ENV["WRITEIT_BASE_URL"] && resource.to_councillor? && resource.writeit_message_id
      button_to("Load replies from WriteIt", load_replies_admin_comment_path)
    end
  end

  member_action :load_replies, method: :post do
    replies = resource.create_replies_from_writeit!
    if replies.present?
      # TODO: Fix pluralisation: "Loaded 1 replies"
      redirect_to({ action: :show }, notice: "Loaded #{replies.count} replies")
    else
      redirect_to({ action: :show }, notice: "No replies loaded")
    end
  end

  action_item :confirm, only: :show do
    if resource.confirmed?
    else
      button_to("Confirm", confirm_admin_comment_path)
    end
  end

  member_action :confirm, method: :post do
    resource.confirm!
    redirect_to({ action: :show }, notice: "Comment confirmed and sent")
  end

  permit_params :text, :email, :name, :address, :hidden
end
