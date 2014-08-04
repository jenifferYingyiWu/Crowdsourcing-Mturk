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
		// add '?t='+Math.random() to prevent caching. Makes webserver realize
		// that we are loading a new (possibly updated) document each time.
		xmlhttp.open('GET', 'TurkHit/tweetCrowdHistory?t=' + Math.random());
		xmlhttp.send();
	}
</script>
</head>
<body>
<?php
	/*
	exec("cd TurkHit; java -cp \".:external_jars/*\" turkhit.TurkHIT"
		. " " . "\"" . $_POST["title"] . "\""
		. " " . "\"" . $_POST["description"] . "\""
		. " " . $_POST["numAssignments"]
		. " " . $_POST["reward"]
		. " " . $_POST["rejectionThreshold"]
		. " " .	$_POST["uploadedFile"]
		. " " . $_POST["keys_of_selected"] 
		. " " . $_POST["minBatchSize"] 
		. " " . $_POST["HITduration"] 
		. " " . $_POST["labelsAvailable"] 
		. " > /dev/null 2>/dev/null &");
	// string added to end to make php process execute asynchronously in background
	*/

	// TESTING GetParams.java
	// java [<option> ...] <class-name> [<argument> ...]
	$output = shell_exec("java GetParams"
		. " " . "\"" . $_POST["title"] . "\""
		. " " . "\"" . $_POST["description"] . "\""
		. " " . $_POST["numAssignments"]
		. " " . $_POST["reward"]
		. " " . $_POST["rejectionThreshold"]
		. " " .	$_POST["uploadedFile"]
		. " " . $_POST["keys_of_selected"] 
		. " " . $_POST["minBatchSize"] 
		. " " . $_POST["HITduration"] 
		. " " . $_POST["labelsAvailable"] . " 2>&1");
		echo "<pre>$output<pre>";
	
?>
<input type="button" value="See Crowd History" onclick="loadXMLDoc()">
<pre id="crowdHistory"></pre>
</body>
</html>
