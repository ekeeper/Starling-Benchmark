-- phpMyAdmin SQL Dump
-- version 3.4.7
-- http://www.phpmyadmin.net
--
-- Хост: localhost
-- Время создания: Апр 13 2012 г., 00:10
-- Версия сервера: 5.0.51
-- Версия PHP: 5.3.9-2

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `starling_benchmark`
--

-- --------------------------------------------------------

--
-- Структура таблицы `devices`
--

CREATE TABLE IF NOT EXISTS `devices` (
  `id` int(11) NOT NULL auto_increment,
  `mac` varchar(64) NOT NULL,
  `manufacturer` varchar(255) NOT NULL,
  `model` varchar(255) NOT NULL,
  `os` varchar(64) NOT NULL,
  `osVersion` varchar(64) NOT NULL,
  `cpu` varchar(64) NOT NULL,
  `cpuHz` varchar(64) NOT NULL,
  `ram` varchar(64) NOT NULL,
  `screenWidth` int(11) NOT NULL,
  `screenHeight` int(11) NOT NULL,
  `dpi` int(11) NOT NULL,
  `ip` varchar(64) NOT NULL,
  `country` varchar(64) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=44 ;

-- --------------------------------------------------------

--
-- Структура таблицы `statistics`
--

CREATE TABLE IF NOT EXISTS `statistics` (
  `id` bigint(11) NOT NULL auto_increment,
  `device_id` int(11) NOT NULL,
  `benchmarkName` varchar(64) NOT NULL,
  `benchmarkVersion` varchar(16) NOT NULL,
  `starlingVersion` varchar(16) NOT NULL,
  `screenWidth` int(11) NOT NULL,
  `screenHeight` int(11) NOT NULL,
  `driver` varchar(255) NOT NULL,
  `memory` float NOT NULL,
  `time` int(11) NOT NULL,
  `objects` int(11) NOT NULL,
  `type` varchar(64) NOT NULL,
  `fps` float NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=482 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
