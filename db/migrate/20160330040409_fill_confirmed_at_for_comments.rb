class FillConfirmedAtForComments < ActiveRecord::Migration
  def change
    Comment.confirmed.each do |comment|
      if comment.confirmed_at.nil?
        comment.update!(confirmed_at: comment.updated_at)
      end
    end
  end
end
