ActiveAdmin.register Subscription do
  index do
    column :email
    column(:active_alerts) { |s| s.alerts.active.count }
    column(:trial?) do |s|
      s.trial? ? status_tag("yes", :ok) : status_tag("no")
    end
    column(:paid?) do |s|
      s.paid? ? status_tag("yes", :ok) : status_tag("no")
    end
    column(:free?) do |s|
      s.free? ? status_tag("yes", :ok) : status_tag("no")
    end
    column :stripe_plan_id
    column :stripe_customer_id
    column :stripe_subscription_id
    column :free_reason
    column :trial_started_at
    actions
  end

  filter :email
  filter :stripe_customer_id
  filter :stripe_subscription_id
  filter :trial_started_at

  sidebar :rollout_status, priority: 0, only: :index do
    "#{Alert.potential_subscribers.without_subscription.count.size} potential subscribers remain. " +
    "#{Alert.potential_subscribers.in_past_week.count.size} new this week."
  end

  form do |f|
    inputs "Details" do
      input :email
    end

    inputs "Paid" do
      input :stripe_plan_id, as: :select, collection: Subscription::PLAN_IDS
      input :stripe_customer_id
      input :stripe_subscription_id
    end

    inputs "Freebie" do
      input :free_reason
    end

    inputs "Trial" do
      input :trial_started_at
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
    column :free_reason
    column :trial_started_at
    column :created_at
    column :updated_at
  end

  permit_params :email, :stripe_plan_id, :stripe_customer_id, :stripe_subscription_id, :trial_started_at, :free_reason
end
