

CREATE TABLE project (

  pid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(3) NOT NULL UNIQUE,
  aid                 INT NOT NULL,

  KEY name_idx (name)

);



CREATE TABLE sample (

  sid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pid                 INT NOT NULL,
  name                VARCHAR(8) NOT NULL  UNIQUE,

  KEY name_idx (name),
  KEY pid_idx  (pid)
);


CREATE TABLE analysis (
  aid                INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  reference	     VARCHAR(100),
  pipeline	     VARCHAR(100)
);


CREATE TABLE status (
  pid                INT NOT NULL,
  status	     VARCHAR(100)
  stamp               BIGINT,
);


