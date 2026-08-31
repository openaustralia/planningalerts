# frozen_string_literal: true

class AddSignupIpToAlertsAndUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :alerts, :signup_ip, :string,
               comment: "IP the alert was created from. Nulled out by ExpireSignupIpsJob after 90 days"
    add_column :users, :signup_ip, :string,
               comment: "IP the account was created from. Nulled out by ExpireSignupIpsJob after 90 days"
  end
end
