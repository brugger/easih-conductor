

CREATE TABLE project (

  pid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(3) NOT NULL UNIQUE,
  aid                 INT,

  KEY name_idx (name)

);



CREATE TABLE sample (

  sid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pid                 INT NOT NULL,
  name                VARCHAR(8) NOT NULL UNIQUE,

  KEY name_idx (name),
  KEY pid_idx  (pid)
);



CREATE TABLE file (

  fid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  sid                 INT NOT NULL ,
  rid		      INT NOT NULL,
  name                VARCHAR(50) NOT NULL ,
  timestamp           BIGINT,

  KEY name_idx (name),
  KEY sid_idx  (sid)
);


CREATE TABLE run (

  rid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  mid		      INT NOT NULL,
  name                VARCHAR(100) NOT NULL UNIQUE,

  KEY name_idx (name)
);

CREATE TABLE sequencer (

  mid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(100) NOT NULL UNIQUE,
  platform            VARCHAR(50),
  
  KEY name_idx (name)
);


CREATE TABLE analysis (
  aid                INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  reference	     VARCHAR(100),
  pipeline	     VARCHAR(100),
  min_reads          INT
);


CREATE TABLE status (
  sid                INT NOT NULL,
  status	     VARCHAR(100),
  stamp              BIGINT
);


