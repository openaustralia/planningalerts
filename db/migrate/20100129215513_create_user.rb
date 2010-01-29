class CreateUser < ActiveRecord::Migration
  def self.up
    execute <<-EOF
    CREATE TABLE `user` (
      `user_id` int(11) NOT NULL AUTO_INCREMENT,
      `email` varchar(120) NOT NULL,
      `address` varchar(120) NOT NULL,
      `digest_mode` tinyint(1) NOT NULL DEFAULT '0',
      `last_sent` datetime DEFAULT NULL,
      `lat` double NOT NULL,
      `lng` double NOT NULL,
      `confirm_id` varchar(20) DEFAULT NULL,
      `confirmed` tinyint(1) DEFAULT NULL,
      `area_size_meters` int(6) NOT NULL,
      PRIMARY KEY (`user_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    EOF
  end

  def self.down
    drop_table :user
  end
end
