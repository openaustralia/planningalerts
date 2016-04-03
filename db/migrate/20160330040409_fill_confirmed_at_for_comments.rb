class FillConfirmedAtForComments < ActiveRecord::Migration
  def change
    Comment.fill_confirmed_at_for_existing_confirmed_comments
  end
end
