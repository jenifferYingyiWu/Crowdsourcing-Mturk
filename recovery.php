<!DOCTYPE html>
<?php 
	if (!empty($_POST)) {
		$to = mysql_real_escape_string($_POST['emailAddress']);
		

		$subject = 'Account Recovery';
		$body = 'Username: ' . 
		mail($to, $subject, $body, $headers);		
	}
?>
<html>
<head>
<title>Account Recovery</title>
</head>
<body>
<form method="POST" action="recovery.php">
<p>Enter the email address used to sign up for this account:<p>
<input type="text" name="emailAddress">
<input type="submit">
</form>
</body>
</html>
