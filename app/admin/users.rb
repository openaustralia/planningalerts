# typed: false
# frozen_string_literal: true

ActiveAdmin.register User do
  actions :all

  index download_links: false do
    column :email
    column :name
    column :organisation
    column :admin
    actions
  end

  form do |f|
    inputs "Details" do
      input :email
      input :name
      input :organisation
      input :admin
    end
    inputs "API" do
      f.has_many :api_keys, new_record: false, heading: false do |a|
        a.input :disabled
        a.input :value
        a.input :bulk
        a.input :commercial, hint: "Are they a paying commercial customer?"
        a.input :daily_limit, hint: "Override default daily number of allowed API requests"
      end
    end
    actions
  end

  permit_params :email, :name, :organisation, :admin,
                api_keys_attributes: %i[id value bulk commercial daily_limit disabled]
end
