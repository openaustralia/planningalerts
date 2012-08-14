ActiveAdmin.register User do
  index :download_links => false do
    column :email
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end

    f.buttons
  end
end
