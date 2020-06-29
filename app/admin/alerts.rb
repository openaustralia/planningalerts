# typed: false
# frozen_string_literal: true

ActiveAdmin.register Alert do
  menu label: "Alerts"
  actions :index, :show

  scope :all, default: true
  scope :active

  index title: "Alerts" do
    column :email
    column :address
    column :lat
    column :lng
    column :confirmed
    column :unsubscribed
    column :created_at
    column :updated_at
    actions
  end

  remove_filter :subscription

  collection_action :export_active_emails, method: :get do
    send_data Alert.active.select(:email).distinct.pluck(:email).join("\n"), filename: "emails.txt"
  end

  action_item :export do
    link_to "Export active email addresses",
            export_active_emails_admin_alerts_path,
            title: "Export a text file containing all email addresses with an active alert set up"
  end

  action_item :unsubscribe, only: :show do
    button_to "Unsubscribe", unsubscribe_admin_alert_path
  end

  member_action :unsubscribe, method: :post do
    alert = Alert.find(params[:id])
    alert.unsubscribe!
    redirect_to(action: :show)
  end
end
