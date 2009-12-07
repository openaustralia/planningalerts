-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.24-standard


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema planning
--

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
  `lat` double NOT NULL,
  `lng` double NOT NULL,
  `date_scraped` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_recieved` date DEFAULT NULL,
  `map_url` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `authority` (
  `authority_id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(200) NOT NULL,
  `short_name` varchar(100) NOT NULL,
  `planning_email` varchar(100) NOT NULL,
  `feed_url` varchar(255) DEFAULT NULL,
  `external` tinyint(1) DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`authority_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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

CREATE TABLE `stats` (
  `key` varchar(25) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO `planning`.`stats` (`key`,`value`) VALUES 
 ('applications_sent',0),
 ('emails_sent',0);



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
