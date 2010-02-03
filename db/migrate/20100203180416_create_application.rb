class CreateApplication < ActiveRecord::Migration
  def self.up
    execute <<-EOF
    CREATE TABLE `application` (
      `application_id` int(11) NOT NULL AUTO_INCREMENT,
      `council_reference` varchar(50) NOT NULL,
      `address` text NOT NULL,
      `postcode` varchar(10) NOT NULL,
      `description` text,
      `info_url` varchar(1024) DEFAULT NULL,
      `info_tinyurl` varchar(50) DEFAULT NULL,
      `comment_url` varchar(1024) DEFAULT NULL,
      `comment_tinyurl` varchar(50) DEFAULT NULL,
      `authority_id` int(11) NOT NULL,
      `lat` double DEFAULT NULL,
      `lng` double DEFAULT NULL,
      `date_scraped` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `date_recieved` date DEFAULT NULL,
      `map_url` varchar(150) DEFAULT NULL,
      PRIMARY KEY (`application_id`),
      KEY `authority_id` (`authority_id`),
      CONSTRAINT `application_ibfk_1` FOREIGN KEY (`authority_id`) REFERENCES `authority` (`authority_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    EOF
  end

  def self.down
    drop_table :application
  end
end
