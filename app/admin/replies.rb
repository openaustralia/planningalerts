# frozen_string_literal: true

ActiveAdmin.register Reply do
  actions :all

  index do
    column :text, sortable: false do |reply|
      truncate(reply.text)
    end
    column :councillor
    column :received_at
    column :comment
    actions
  end

  remove_filter :comment

  form do |_f|
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
