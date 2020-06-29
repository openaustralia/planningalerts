# typed: false
# frozen_string_literal: true

ActiveAdmin.register Application do
  actions :index, :show, :destroy

  index do
    column :council_reference
    column :address
    column :description
    column :authority
    actions
  end

  remove_filter :comments
  remove_filter :versions
  remove_filter :current_version

  show title: :address do
    attributes_table do
      row :id
      row :council_reference
      row :address
      row :description
      row :info_url
      row :authority
      row :lat
      row :lng
      row :date_scraped
      row :date_received
      row :suburb
      row :state
      row :postcode
      row :on_notice_from
      row :on_notice_to
      row :no_alerted
    end
  end

  sidebar :comments, only: :show do
    ul do
      resource.comments.each do |comment|
        li do
          link_to(comment.text, admin_comment_path(comment)) + " by " + comment.name
        end
      end
    end
    div "All comments are shown here including unconfirmed and hidden ones"
  end
end
