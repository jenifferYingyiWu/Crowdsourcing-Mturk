DROP DATABASE IF EXISTS cs_mturk;
CREATE DATABASE cs_mturk;
USE cs_mturk;
CREATE TABLE members (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	username VARCHAR(30) NOT NULL, 
	email VARCHAR(50) NOT NULL,
	salt CHAR(128) NOT NULL,
	encryptedPassword CHAR(128) NOT NULL
); 
