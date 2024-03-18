class RemoveCommentsToCouncillorsData < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Comment.where("councillor_id IS NOT NULL").destroy_all
      end

      dir.down do
        # We can't reinstate the deleted data but there's little point in failing here
      end
    end
  end
end
