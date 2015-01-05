ActiveAdmin.register Alert do
  actions :all, except: [:new, :create]

  index do
    column :email
    column :address
    column :lat
    column :lng
    column :confirmed
    column :unsubscribed
    column :created_at
    column :updated_at
    default_actions
  end

  # TODO: Don't export duplicates
  collection_action :export_active_emails, method: :get do
    emails = ''
    Alert.active.find_each do |alert|
      emails += alert.email + "\n"
    end
    send_data emails, filename: 'emails.txt'
  end

  action_item do
    link_to "Export active email addresses", export_active_emails_admin_alerts_path
  end
end
