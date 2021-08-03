# typed: false
# frozen_string_literal: true

ActiveAdmin.register User do
  actions :all

  index download_links: false do
    column :email
    column :name
    column :organisation
    column :api_key
    column :api_disabled
    column :unlimited_api_usage
    column :bulk_api
    column :admin
    actions
  end

  form do |_f|
    inputs "Details" do
      input :email
      input :name
      input :organisation
    end
    inputs "API" do
      input :api_disabled
      input :api_key
      input :unlimited_api_usage
      input :bulk_api
      input :api_commercial, hint: "Are they a paying commercial customer?"
    end
    inputs "Administration" do
      input :admin
    end
    actions
  end

  permit_params :email, :name, :organisation, :api_key, :unlimited_api_usage, :bulk_api, :api_commercial, :admin, :api_disabled
end
