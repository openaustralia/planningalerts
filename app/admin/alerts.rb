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
end
