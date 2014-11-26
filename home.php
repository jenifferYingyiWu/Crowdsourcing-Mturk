<?php
session_start();
if (!(isset($_SESSION['loggedin']) || $_SESSION['loggedin'] == true)) {
	header('Location: login.html');
	die();
}
?>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
<title>Home</title>
<style>
ul li a {
	width: 220px;
}
</style>
</head>
<body>
<?php echo '<h3>Welcome, ' . $_SESSION['username'] . '!</h3>'; ?>
<ul class="nav nav-pills nav-stacked">  
<li><a href="uploadFiles.php">Crowdsource Labels</a></li>
<li><a href="viewResults.php">View Previous Results</a></li>
<li><a href="changeKeys.html">Change Access Keys</a></li>
<li><a href="logout.php">Logout</a></li>
</ul>

</body>
</html>
