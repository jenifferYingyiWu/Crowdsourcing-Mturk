<?php
	session_start();
	include('connection.php');
	
	$accessKeyID = mysql_real_escape_string($_POST['accessKeyID']);
	$secretAccessKey = mysql_real_escape_string($_POST['secretAccessKey']);
	$username = $_SESSION['username'];

	$sql = "UPDATE members
			SET accessKeyID = '$accessKeyID', secretAccessKey = '$secretAccessKey'
			WHERE username = '$username'";
	$result = mysql_query($sql);
	if (!$result) 
		die('Invalid query: ' . mysql_error());

	header('location: home.php');
?>
