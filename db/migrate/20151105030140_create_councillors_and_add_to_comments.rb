class CreateCouncillorsAndAddToComments < ActiveRecord::Migration
  def change
    create_table :councillors do |t|
      t.string :name
      t.string :image_url
      t.string :party

      t.timestamps
    end

    add_reference :comments, :councillor
  end
end
