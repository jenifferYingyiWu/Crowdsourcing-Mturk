<?php
	$output = shell_exec("java GetParams"
		. " " .  "\"" . $_POST['title'] . "\""
		. " " .  "\"" . $_POST['description'] . "\""
		. " " .  $_POST['numAssignments']
		. " " .  $_POST['reward']
		. " " .  $_POST['percentFailed']
		. " " .  $_POST['tweetIDs']);
	echo "<pre>$output<pre>";
?>
