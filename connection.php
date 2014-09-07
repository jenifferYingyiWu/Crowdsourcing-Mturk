<?php
$db_host = 'localhost';
$db_username = 'root';
$db_password = 'umdb2014';
$db_name = 'login';

mysql_connect($db_host, $db_username, $db_password)
	or die("Failed to connect to MySQL.");
mysql_select_db($db_name)
	or die("Failed to select database.");
?>
