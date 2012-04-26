

CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL,
  `password` varchar(64) NOT NULL,

  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;


CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `groupname` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `groupname` (`groupname`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE user_group (
  user_id INT NOT NuLL,
  group_id INT NOT NULL,

  PRIMARY KEY (user_id, group_id),
  index uid_idx (user_id),
  index gid_idx (group_id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
  

          