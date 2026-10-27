# frozen_string_literal: true

class AddCommentsDisabledToApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :applications, :comments_disabled, :boolean, default: false, null: false
    add_column :applications, :comments_disabled_reason, :text
  end
end
