# localhost access only
CREATE USER 'easih_ro'@'localhost';
GRANT SELECT ON *.* TO 'easih_ro'@'localhost';

CREATE USER 'easih_admin'@'localhost' IDENTIFIED BY 'easih';
GRANT ALL PRIVILEGES ON *.* TO 'easih_admin'@'localhost' WITH GRANT OPTION;
