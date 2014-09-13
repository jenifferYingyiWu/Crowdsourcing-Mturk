<?php
	session_start();
	
	$accessKeyID = mysql_real_escape_string($_POST['accessKeyID']);
	$secretAccessKey = mysql_real_escape_string($_POST['secretAccessKey']);
	$username = $_SESSION['username'];

	$text = file_get_contents('MTurkCrowdSourcing/mturk.properties');	
	$text = preg_replace('/access_key=.*/', 'access_key=' . $accessKeyID, $text);
	$text = preg_replace('/secret_key=.*/', 'secret_key=' . $secretAccessKey, $text);
	file_put_contents('users/' . $username . '/mturk.properties', $text);
	
	header('location: home.php');
?>
