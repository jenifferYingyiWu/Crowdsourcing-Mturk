<!DOCTYPE html>
<html>
<head>
<title>View Results</title>
</head>
<body>
<?php
session_start();
foreach (new DirectoryIterator('users/' . $_SESSION['username']) as $fileInfo) {
	if ($fileInfo->isDot()) // skip . or ..
		continue;
	echo "<b>" . $fileInfo->getFilename() . "</b>";
	$contents = split("\n", 
		file_get_contents('users/' . $_SESSION['username'] . '/' . $fileInfo->getFilename()));
	$i = count($contents) - 3;
	$endText = "";
	while (strlen($contents[$i]) != 0) {
		$endText = ("<br>" . $contents[$i]) . $endText;
		$i--;
	}
	echo $endText . "<br><br>";
}
?>
</body>
</html>
