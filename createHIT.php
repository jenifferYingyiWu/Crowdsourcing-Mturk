<!DOCTYPE html>
<html>
<head>
<title>HIT Created</title>
</head>
<body>
<?php
	$output = shell_exec("java GetParams"
		. " " . "\"" . $_POST['title'] . "\""
		. " " . "\"" . $_POST['description'] . "\""
		. " " . $_POST['numAssignments']
		. " " . $_POST['reward']
		. " " . $_POST['percentFailed']
		. " " .	$_POST['uploadedFile']
		. " " . $_POST['tweetIDs']);
	echo "<pre>$output<pre>";
?>
<a href="crowdHistory.txt" target="_blank">See Crowd History</a>
</body>
</html>
