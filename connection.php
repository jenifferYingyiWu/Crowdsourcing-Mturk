<?php
$db_host = '127.0.0.1';
$db_username = 'cs_mturk';
$db_password = 'umdb2014';
$db_name = 'cs_mturk';

mysql_connect($db_host, $db_username, $db_password)
	or die("Failed to connect to MySQL.");
mysql_select_db($db_name)
	or die("Failed to select database.");
?>
