<!DOCTYPE html>
<html>
<head>
<title>Home</title>
<style>
ul {
	list-style-type: none;
	margin: 0;
	padding: 0;
}
li { margin-bottom: 10px; }
a { text-decoration: none; }
a:visited { color: blue; }
</style>
</head>
<body>
<?php
session_start();
echo '<h3>Welcome, ' . $_SESSION['username'] . '!</h3>';
?>
<ul>
<li><a href="uploadFiles.html">Crowdsource Labels</a></li>
<li><a href="viewResults.php">View Previous Results</a></li>
<li><a href="changeKeys.html">Change Access Keys</a></li>
<li><a href="logout.php">Logout</a></li>
</ul>
</div>
</body>
</html>
