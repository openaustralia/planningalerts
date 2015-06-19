ActiveAdmin.register Alert do
  menu label: "Alerts"
  actions :all, except: [:new, :create]

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
    emails = []
    Alert.active.find_each do |alert|
      emails << alert.email
    end
    emails.uniq! # TODO: Use ActiveRecord's `distinct` when we upgrade Rails
    send_data emails.join("\n"), filename: 'emails.txt'
  end

  action_item :export do
    link_to "Export active email addresses",
            export_active_emails_admin_alerts_path,
            title: "Export a text file containing all email addresses with an active alert set up"
  end
end
