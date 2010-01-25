class CreateStats < ActiveRecord::Migration
  def self.up
    #execute <<-EOF
    #CREATE TABLE `stats` (
    #  `key` varchar(25) NOT NULL,
    #  `value` int(11) NOT NULL,
    #  PRIMARY KEY (`key`)
    #) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    #EOF
    create_table :stats, :force => true do |t|
      t.column :key, :string
      t.column :value, :integer
    end
  end

  def self.down
    drop_table :stats
  end
end


