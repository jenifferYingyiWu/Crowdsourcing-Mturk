<!DOCTYPE html>
<html>
<head>
<title>HIT Created</title>
<script type="text/javascript">
	function loadXMLDoc() {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onload = function() {
			document.getElementById('crowdHistory').textContent = xmlhttp.responseText;
		}
		// add '?t='+Math.random() to prevent caching. Need it make is realize
		// that we are loading a new (possibly updated) document each time.
		xmlhttp.open('GET', 'crowdHistory.txt?t=' + Math.random(), true);
		xmlhttp.send();
	}
</script>
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
<input type="button" value="See Crowd History" onclick="loadXMLDoc()">
<pre id="crowdHistory"></pre>
</body>
</html>
