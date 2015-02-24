ActiveAdmin.register User do
  index :download_links => false do
    column :email
    column :name
    column :organisation
    column :bulk_api
    column :admin
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :name
      f.input :organisation
      f.input :bulk_api
      # Only show password fields when creating new user
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
      f.input :admin
    end

    f.buttons
  end
end
