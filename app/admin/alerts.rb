ActiveAdmin.register Alert do
  menu label: "Alerts"
  actions :index, :show

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

  collection_action :export_active_emails, method: :get do
    send_data Alert.active.select(:email).distinct.pluck(:email).join("\n"), filename: 'emails.txt'
  end

  action_item :export do
    link_to "Export active email addresses",
            export_active_emails_admin_alerts_path,
            title: "Export a text file containing all email addresses with an active alert set up"
  end
end
