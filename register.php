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
		
		mkdir('users/' . $username);
		chmod('users/' . $username, 0777);
		$text = file_get_contents('MTurkCrowdSourcing/mturk.properties');	
		$text = preg_replace('/access_key=.*/', 'access_key=' . $accessKeyID, $text);
		$text = preg_replace('/secret_key=.*/', 'secret_key=' . $secretAccessKey, $text);
		file_put_contents('users/' . $username . '/mturk.properties', $text);

		mkdir('users/' . $username . '/results');
		chmod('users/' . $username . '/results', 0777);

		mkdir('users/' . $username . '/params');
		chmod('users/' . $username . '/params', 0777);

		$randText = md5(uniqid(rand(), true));
		$salt = substr($randText, 0, 3);
		$encryptedPassword = hash('sha256', $salt . $password);

		$sql = "INSERT INTO members (username, email, salt,	encryptedPassword)
				VALUES ('$username', '$email', '$salt', '$encryptedPassword')";
		$result = mysql_query($sql);
		if (!$result) 
			die('Invalid query: ' . mysql_error());
		mysql_close();

		header('location: login.html');
	}
	else 
		header('location: register.html');
?>
