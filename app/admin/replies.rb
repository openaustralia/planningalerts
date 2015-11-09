ActiveAdmin.register Reply do
  actions :all

  remove_filter :comment

  form do |f|
    inputs do
      input :comment_id, as: :number, label: "Comment ID"
      input :councillor
      input :text
      input :received_at
    end
    actions
  end

  permit_params :text, :received_at, :comment_id, :councillor_id
end
