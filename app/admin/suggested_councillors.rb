ActiveAdmin.register SuggestedCouncillor do
  menu false
  actions :edit, :update

  controller do
    def update
      super do |success, failure|
        success.html { redirect_to admin_councillor_contribution_path(resource.councillor_contribution) }
      end
    end
  end

  form do |f|
    inputs "Details" do
      input :name
      input :email
    end
    f.actions do
      action(:submit)
      cancel_link(admin_councillor_contribution_path(resource.councillor_contribution))
    end
  end

  permit_params :name, :email
end
