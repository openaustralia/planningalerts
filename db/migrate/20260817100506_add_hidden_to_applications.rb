# frozen_string_literal: true

class AddHiddenToApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :applications, :hidden, :boolean, default: false, null: false
    add_column :applications, :hidden_reason, :text
    add_index :applications, :hidden
  end
end
