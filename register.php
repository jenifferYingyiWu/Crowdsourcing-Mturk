<?php
	session_start();
	include('connection.php');
	
	$username = mysql_real_escape_string($_POST['username']);
	$email = mysql_real_escape_string($_POST['email']);
	$password1 = mysql_real_escape_string($_POST['password1']);
	$password2 = mysql_real_escape_string($_POST['password2']);
	$accessKeyID = mysql_real_escape_string($_POST['accessKeyID']);
	$secretAccessKey = mysql_real_escape_string($_POST['secretAccessKey']);

	if ($password1 == $password2) {
		$randText = md5(uniqid(rand(), true));
		$salt = substr($randText, 0, 3);
		$encryptedPassword = hash('sha256', $salt . $password1);

		$table_name = 'members';
		$sql = "INSERT INTO $table_name (username, encryptedPassword, email, salt, accessKeyID, secretAccessKey)
				VALUES ('$username', '$encryptedPassword', '$email', '$salt', '$accessKeyID', '$secretAccessKey')";	
		$result = mysql_query($sql);
		if (!$result) 
			die('Invalid query: ' . mysql_error());
		mysql_close();
		
		mkdir('users/' . $username, 0777, true);
		chmod('users/' . $username, 0777);

		$_SESSION['username'] = $username;
		header('location: home.php');
	}
	else 
		header('location: register.html');
?>
