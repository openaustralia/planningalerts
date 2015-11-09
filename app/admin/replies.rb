ActiveAdmin.register Reply do
  actions :all

  permit_params :text, :received_at, :comment_id, :councillor_id
end
