ActiveAdmin.register Authority do
  actions :all, :except => [:destroy, :new, :create]

  scope :active, :default => true
  scope :all

  index do
    column "Name", :full_name
    column :state
    default_actions
  end
end
