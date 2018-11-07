# frozen_string_literal: true

ActiveAdmin.register Report do
  actions :index, :show, :destroy

  scope(:comment_not_hidden, default: true) { |r| r.joins(:comment).where(comments: { hidden: false }) }
  scope :all

  filter :name
  filter :email
  filter :details

  index do
    column :created_at
    column :name
    column :email
    column :details do |report|
      truncate(report.details)
    end
    column :comment
    actions
  end
end
