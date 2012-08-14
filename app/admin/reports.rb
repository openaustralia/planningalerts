ActiveAdmin.register Report do
  actions :all, :except => [:destroy, :new, :create] 
end
