<?php
	session_start();
	include('connection.php');
	
	$username = mysql_real_escape_string($_POST['username']);
	$password = mysql_real_escape_string($_POST['password']);

	$table_name = 'members';
	$sql = "SELECT id, username, encryptedPassword, salt 
			FROM $table_name 
			WHERE username = '$username'";
	$result = mysql_query($sql);
	if (!$result) 
		die('Invalid query: ' . mysql_error());

	if(mysql_num_rows($result) == 1) {
		$userData = mysql_fetch_array($result, MYSQL_ASSOC);
		mysql_close();
		$password_encrypted = hash('sha256', $userData['salt'] . $password);
		if ($password_encrypted == $userData['encryptedPassword']) {
			$_SESSION['username'] = $username;
			header('location: home.php');
		}
		else
			header('location: login.html');
	} 
	else
		header('location: login.html');
?>
