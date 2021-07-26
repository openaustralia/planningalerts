class CreateReplies < ActiveRecord::Migration[4.2]
  def change
    create_table :replies do |t|
      t.text :text
      t.datetime :received_at
      t.references :comment, index: true
      t.references :councillor, index: true
    end
  end
end
