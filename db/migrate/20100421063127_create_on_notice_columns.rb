class CreateOnNoticeColumns < ActiveRecord::Migration[4.2]
  def self.up
    change_table(:applications) do |t|
      t.date :on_notice_from
      t.date :on_notice_to
    end
  end

  def self.down
    change_table(:applications) do |t|
      t.remove :on_notice_from, :on_notice_to
    end
  end
end
