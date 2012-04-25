

CREATE TABLE project (

  pid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  aid                 INT,
  name                VARCHAR(3) NOT NULL UNIQUE,
  notes		      TEXT,

  KEY name_idx (name)
);


CREATE TABLE project_status (
  pid                INT NOT NULL,
  status	     VARCHAR(100),
  stamp              BIGINT,

  KEY pid_idx ( pid )
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

  KEY name_idx (name),
  KEY sid_idx  (sid),
  KEY rid_idx  (rid)
);

CREATE TABLE run (

  rid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  mid		      INT NOT NULL,
  name                VARCHAR(100) NOT NULL UNIQUE,
  
  KEY name_idx (name)
);

CREATE TABLE sample_sheet (

  rid                 INT NOT NULL,
  lane		      INT, 
  sample_name         VARCHAR(30) NOT NULL,
  barcode 	      VARCHAR(20),
  
  KEY name_idx (sample_name)
);

CREATE TABLE sequencer (

  mid                 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(100) NOT NULL UNIQUE,
  platform            VARCHAR(50),  
  center	      VARCHAR(50),   

  KEY name_idx (name)
);


CREATE TABLE analysis (
  aid                INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  descr		     TEXT,
  reference	     VARCHAR(100),
  pipeline	     VARCHAR(100),
  min_reads          INT
);


CREATE TABLE run_status (
  rid                INT NOT NULL,
  status	     VARCHAR(100),
  stamp              BIGINT
);

CREATE TABLE file_status (
  fid                INT NOT NULL,
  status	     VARCHAR(100),
  stamp              BIGINT,

  KEY fid_idx ( fid )
);

CREATE TABLE sample_analysis_status (
  sid                INT NOT NULL,
  status	     VARCHAR(100),
  stamp              BIGINT,

  KEY sid_idx ( sid )
);



CREATE TABLE sample_crr (
  sid                INT NOT NULL,
  task 	             INT,
  type 	             VARCHAR(20),
  count 	     INT,

  KEY fid_idx ( sid )
);

