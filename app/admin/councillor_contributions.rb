# typed: false
# frozen_string_literal: true

ActiveAdmin.register CouncillorContribution do
  actions :index, :show

  index do
    column(:contributor, &:attribution)
    column :created_at
    column :authority
    column :reviewed
    column :accepted

    actions
  end

  show title: proc { |resource| "Councillor Contribution for #{resource.authority.full_name}, #{resource.created_at.strftime('%B %d, %Y')}" } do
    attributes_table do
      row(:contributor) { |contribution| contribution.attribution(with_email: true) }
      row :source
    end

    h3 "Suggested Councillors"
    table_for resource.suggested_councillors, class: "index_table" do
      column :name
      column :email
      column "Actions" do |suggested_councillor|
        link_to "Edit", edit_admin_suggested_councillor_path(suggested_councillor)
      end
    end
  end

  action_item :download, only: [:show] do
    link_to "Download the suggested councillors CSV", authority_councillor_contribution_path(resource.authority, resource.id, format: :csv)
  end

  member_action :toggle_reviewed, method: :patch do
    resource.toggle("reviewed")
    resource.accepted = false unless resource.reviewed?
    resource.save!

    redirect_to(action: :show)
  end

  member_action :toggle_accepted, method: :patch do
    resource.toggle("accepted")
    resource.save!

    redirect_to(action: :show)
  end

  action_item :toggle_reviewed, only: [:show] do
    button_to "Mark as #{'not ' if resource.reviewed}reviewed", toggle_reviewed_admin_councillor_contribution_path, method: :patch
  end

  action_item :toggle_reviewed, only: [:show] do
    if resource.reviewed
      button_to "Mark as #{'not ' if resource.accepted}accepted", toggle_accepted_admin_councillor_contribution_path, method: :patch
    end
  end

  permit_params :contributor, :created_at, :authority, :suggested_councillors_id, :reviewed
end
