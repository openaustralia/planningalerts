# frozen_string_literal: true

class AddCommentsDisabledToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :comments_disabled, :boolean, default: false, null: false
    add_column :users, :comments_disabled_reason, :text
  end
end
