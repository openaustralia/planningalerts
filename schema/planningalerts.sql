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

CREATE DATABASE IF NOT EXISTS planning;
USE planning;

CREATE TABLE  `planning`.`application` (
  `application_id` int(11) NOT NULL auto_increment,
  `council_reference` varchar(50) NOT NULL,
  `address` text NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `description` text,
  `info_url` varchar(1024) default NULL,
  `info_tinyurl` varchar(50) default NULL,
  `comment_url` varchar(1024) default NULL,
  `comment_tinyurl` varchar(50) default NULL,
  `authority_id` int(11) NOT NULL,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `date_scraped` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `date_recieved` date default NULL,
  `map_url` varchar(150) default NULL,
  PRIMARY KEY  (`application_id`)
) ENGINE=MyISAM AUTO_INCREMENT=972 DEFAULT CHARSET=utf8;

CREATE TABLE  `planning`.`authority` (
  `authority_id` int(11) NOT NULL auto_increment,
  `full_name` varchar(200) NOT NULL,
  `short_name` varchar(100) NOT NULL,
  `planning_email` varchar(100) NOT NULL,
  `feed_url` varchar(255) default NULL,
  `external` tinyint(1) default NULL,
  `disabled` tinyint(1) default NULL,
  `notes` text,
  PRIMARY KEY  (`authority_id`)
) ENGINE=MyISAM AUTO_INCREMENT=52 DEFAULT CHARSET=utf8;

CREATE TABLE  `planning`.`user` (
  `user_id` int(11) NOT NULL auto_increment,
  `email` varchar(120) NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `digest_mode` tinyint(1) NOT NULL default '0',
  `last_sent` datetime default NULL,
  `bottom_left_x` int(11) default NULL,
  `bottom_left_y` int(11) default NULL,
  `top_right_x` int(11) default NULL,
  `top_right_y` int(11) default NULL,
  `confirm_id` varchar(20) default NULL,
  `confirmed` tinyint(1) default NULL,
  `alert_area_size` varchar(1) default NULL,
  PRIMARY KEY  (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;

CREATE TABLE  `planning`.`stats` (
  `key` varchar(25) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY  (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
