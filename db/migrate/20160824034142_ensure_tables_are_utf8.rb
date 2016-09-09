class EnsureTablesAreUtf8 < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.tables.each do |table_name|
      ActiveRecord::Base.connection.execute "ALTER TABLE #{table_name} CONVERT TO CHARACTER SET utf8"
    end
  end
end
