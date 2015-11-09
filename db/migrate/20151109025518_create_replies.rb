class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.text :text
      t.datetime :received_at
      t.references :comment, index: true
      t.references :councillor, index: true
    end
  end
end
