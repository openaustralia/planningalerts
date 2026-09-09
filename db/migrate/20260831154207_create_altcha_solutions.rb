# frozen_string_literal: true

class CreateAltchaSolutions < ActiveRecord::Migration[7.1]
  def change
    create_table :altcha_solutions do |t|
      # The challenge signature, which is unique per challenge we issue.
      # Recording it is what stops a correct answer being submitted twice.
      t.string :signature, null: false
      t.datetime :expires_at, null: false
      t.datetime :created_at, null: false
    end

    add_index :altcha_solutions, :signature, unique: true
    add_index :altcha_solutions, :expires_at
  end
end
