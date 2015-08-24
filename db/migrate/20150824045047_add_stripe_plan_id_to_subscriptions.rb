class AddStripePlanIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_plan_id, :string
  end
end
