DROP TABLE IF EXISTS `seoul_popular_trip`;
CREATE TABLE `seoul_popular_trip` (
  `category` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `naddress` varchar(100) DEFAULT NULL,
  `tel` varchar(20) DEFAULT NULL,
  `tag` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
LOCK TABLES `seoul_popular_trip` WRITE;
INSERT INTO `seoul_popular_trip` VALUES (0,25931,'통인가게 ','110-300 서울 종로구 관훈동 16 ','03148 서울 종로구 인사동길 32 (관훈동) ','02-733-4867','오래된가게,고미술,통인정신,통인가게,공예샵,          현대공예');
UNLOCK TABLES;
