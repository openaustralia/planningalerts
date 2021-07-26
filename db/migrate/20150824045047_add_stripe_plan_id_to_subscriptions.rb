class AddStripePlanIdToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :stripe_plan_id, :string
  end
end
