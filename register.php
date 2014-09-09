<?php
	session_start();
	include('connection.php');
	
	$username = mysql_real_escape_string($_POST['username']);
	$email = mysql_real_escape_string($_POST['email']);
	$password = mysql_real_escape_string($_POST['password1']);
	$confirmedPassword = mysql_real_escape_string($_POST['password2']);
	$accessKeyID = mysql_real_escape_string($_POST['accessKeyID']);
	$secretAccessKey = mysql_real_escape_string($_POST['secretAccessKey']);

	if ($password == $confirmedPassword) {
		$_SESSION['username'] = $username;
		$randText = md5(uniqid(rand(), true));
		$salt = substr($randText, 0, 3);
		$encryptedPassword = hash('sha256', $salt . $password);

		$sql = "INSERT INTO members (username, email, salt,	
								   encryptedPassword, accessKeyID, secretAccessKey)
				VALUES ('$username', '$email', '$salt', 
						'$encryptedPassword', '$accessKeyID', '$secretAccessKey')";
		$result = mysql_query($sql);
		if (!$result) 
			die('Invalid query: ' . mysql_error());
		mysql_close();

		header('location: home.php');
	}
	else 
		header('location: register.html');
?>
