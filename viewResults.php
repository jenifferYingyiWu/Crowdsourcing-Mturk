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
<title>View Results</title>
<style>
	a:visited { color: blue; }
</style>
</head>
<body>
<?php
$username = $_SESSION['username'];
$resultsDir = 'users/' . $username . '/results/';
$noFiles = True;
foreach (new DirectoryIterator($resultsDir) as $fileInfo) {
	if ($fileInfo->isDot()) // skip . or ..
		continue;
	$noFiles = False;
	echo "<b>" . $fileInfo->getFilename() . "</b>";
	$contents = split("\n", 
		file_get_contents($resultsDir . $fileInfo->getFilename()));
	$i = count($contents) - 3;
	$endText = "";
	while (strlen($contents[$i]) != 0) {
		$endText = ("<br>" . $contents[$i]) . $endText;
		$i--;
	}
	echo $endText . "<br><br>";
}
if ($noFiles)
	echo 'You have not crowdsourced any labels yet.<br><br>';
?>
<a href="home.php">Go Home</a>
</body>
</html>
