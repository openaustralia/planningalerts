class AddUserAgentToApiStatistics < ActiveRecord::Migration[4.2]
  def self.up
    add_column :api_statistics, :user_agent, :text
  end

  def self.down
    remove_column :api_statistics, :user_agent
  end
end
