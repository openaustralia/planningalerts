class RemoveCouncillorsAndRelated < ActiveRecord::Migration[5.2]
  def change
    remove_column :authorities, :write_to_councillors_enabled, :boolean, default: false, null: false

    remove_column :comments, :councillor_id, :integer
    remove_column :comments, :writeit_message_id, :integer

    drop_table :suggested_councillors, id: :integer do |t|
      t.string :name
      t.string :email
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :councillor_contribution_id, null: false
      t.index :councillor_contribution_id
    end

    drop_table :councillor_contributions, id: :integer do |t|
      t.integer :contributor_id
      t.integer :authority_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :source
      t.boolean :reviewed, default: false, null: false
      t.boolean :accepted, default: false, null: false
      t.index :authority_id
      t.index :contributor_id
    end

    drop_table :contributors, id: :integer do |t|
      t.string :name
      t.string :email
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    drop_table :replies, id: :integer do |t|
      t.text :text, limit: 16777215
      t.datetime :received_at
      t.integer :comment_id, null: false
      t.integer :councillor_id, null: false
      t.integer :writeit_id
      t.index :comment_id
      t.index :councillor_id
    end

    drop_table :councillors, id: :integer do |t|
      t.string :name, null: false
      t.string :image_url
      t.string :party
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :email, null: false
      t.integer :authority_id, null: false
      t.string :popolo_id, null: false
      t.boolean :current, default: true, null: false
      t.index :authority_id
    end

    remove_column :email_batches, :no_replies, :integer, null: false
  end
end
