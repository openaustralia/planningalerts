# typed: false
# frozen_string_literal: true

ActiveAdmin.register Donation do
  index do
    column :email
    column(:active_alerts) { |s| s.alerts.active.count }
    column(:paid?) do |s|
      s.paid? ? status_tag("yes", :ok) : status_tag("no")
    end
    column :stripe_plan_id
    column :stripe_customer_id
    column :stripe_subscription_id
    actions
  end

  filter :email
  filter :stripe_customer_id
  filter :stripe_subscription_id

  form do |_f|
    inputs "Details" do
      input :email
    end

    inputs "Paid" do
      input :stripe_plan_id
      input :stripe_customer_id
      input :stripe_subscription_id
    end

    actions
  end

  csv do
    column :id
    column :email
    column(:active_alerts) { |s| s.alerts.active.count }
    column :stripe_plan_id
    column :stripe_customer_id
    column :stripe_subscription_id
    column :created_at
    column :updated_at
  end

  permit_params :email, :stripe_plan_id, :stripe_customer_id, :stripe_subscription_id
end
