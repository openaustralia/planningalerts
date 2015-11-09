ActiveAdmin.register Reply do
  actions :all

  remove_filter :comment

  permit_params :text, :received_at, :comment_id, :councillor_id
end
