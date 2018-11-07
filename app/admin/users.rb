# frozen_string_literal: true

ActiveAdmin.register User do
  actions :all

  index download_links: false do
    column :email
    column :name
    column :organisation
    column :api_key
    column "Total API calls" do |u|
      u.api_statistics.count
    end
    column "API calls in last month" do |u|
      u.api_statistics.where("query_time >= ?", 1.month.ago).count
    end
    column :api_disabled
    column :bulk_api
    column :admin
    actions
  end

  remove_filter :api_statistics

  form do |_f|
    inputs "Details" do
      input :email
      input :name
      input :organisation
    end
    inputs "API" do
      input :api_disabled
      input :api_key
      input :bulk_api
    end
    inputs "Administration" do
      input :admin
    end
    actions
  end

  permit_params :email, :name, :organisation, :api_key, :bulk_api, :admin, :api_disabled
end
