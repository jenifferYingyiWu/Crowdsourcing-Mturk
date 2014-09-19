<?php
	$db_host = '127.0.0.1';
	$db_username = 'cs_mturk';
	$db_password = 'umdb2014';
	$db_name = 'cs_mturk';

	$conn = mysql_connect($db_host, $db_username, $db_password);
	if (!$conn)
		die("Failed to connect to MySQL: " . mysql_error());

	mysql_query("DROP DATABASE IF EXISTS $db_name") or die(mysql_error());	

	$sql = "CREATE DATABASE IF NOT EXISTS $db_name";
	mysql_query($sql, $conn) or die("Error creating database: " . mysql_error());
	
	mysql_select_db($db_name) or die(mysql_error());

	$sql = "CREATE TABLE IF NOT EXISTS members(
		id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		username VARCHAR(30) NOT NULL, 
		email VARCHAR(50) NOT NULL,
		salt CHAR(128) NOT NULL,
		encryptedPassword CHAR(128) NOT NULL
	)"; 
	mysql_query($sql) or die("Error creating members table: " . mysql_error());

	mysql_close($conn);
?>
