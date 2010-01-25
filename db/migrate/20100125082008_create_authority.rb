class CreateAuthority < ActiveRecord::Migration
  def self.up
    execute <<-EOF
    CREATE TABLE `authority` (
      `authority_id` int(11) NOT NULL AUTO_INCREMENT,
      `full_name` varchar(200) NOT NULL,
      `short_name` varchar(100) NOT NULL,
      `planning_email` varchar(100) NOT NULL,
      `feed_url` varchar(255) DEFAULT NULL,
      `external` tinyint(1) DEFAULT NULL,
      `disabled` tinyint(1) DEFAULT NULL,
      `notes` text,
      PRIMARY KEY (`authority_id`),
      UNIQUE KEY `short_name_unique` (`short_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    EOF
  end

  def self.down
    drop_table :authority
  end
end

