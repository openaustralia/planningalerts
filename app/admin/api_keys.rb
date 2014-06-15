ActiveAdmin.register ApiKey do
  form do |f|
    f.inputs "Contact" do
      f.input :contact_name, label: "Name"
      f.input :contact_email, label: "Email"
    end
    f.inputs "Organisation" do
      f.input :organisation, label: "Name"
    end

    f.buttons
  end
end
