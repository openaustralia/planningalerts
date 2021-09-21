# typed: false
# frozen_string_literal: true

ActiveAdmin.register Comment do
  menu label: "Comments"
  actions :all, except: %i[destroy new create]

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

  action_item :resend, only: :show do
    button_to("Resend email", resend_admin_comment_path, disabled: resource.last_delivered_successfully)
  end

  member_action :resend, method: :post do
    resource.send_comment!
    redirect_to({ action: :show }, notice: "Resent comment")
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
