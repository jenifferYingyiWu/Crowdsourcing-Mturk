<!DOCTYPE html>
<html>
<head>
<title>HIT Created</title>
<script type="text/javascript">
	var numSelected = <?php echo json_encode(count(explode(",", $_POST["keys_of_selected"]))); ?>;

	function loadXMLDoc() {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onload = function() {
			var responseText_split = (xmlhttp.responseText).split("\n");
			var responseText = "";
			for (var i = 0; i < 3*numSelected + (numSelected-1); i++)
				responseText += ("\n" + responseText_split[i]);

			responseText += "\n";

			var offset;
			if (responseText_split[responseText_split.length-2].substring(0,7) == "Finish!")
				offset = 4;
			else 
				offset = 2;

			for (var i = responseText_split.length-numSelected-offset; i < responseText_split.length; i++)
				responseText += ("\n" + responseText_split[i]);
			document.getElementById('crowdHistory').textContent = responseText;
		}
		// add '?t='+Math.random() to prevent caching. Makes webserver realize
		// that we are loading a new (possibly updated) document each time.
		xmlhttp.open('GET', 'MTurkCrowdSourcing/history/tweetCrowdHistory?t=' + Math.random());
		xmlhttp.send();
	}
</script>
</head>
<body>
<?php
	/*
	exec("cd TurkHit; java -cp \".:external_jars/*\" mturkcrowdsourcing.MTurkCrowdSourcing"
		. " " .	$_POST["questionFile"] 
		. " " . $_POST["dataFile"] 
		. " " . "\"" . $_POST["title"] . "\""
		. " " . "\"" . $_POST["description"] . "\""
		. " " . $_POST["numAssignments"]
		. " " . $_POST["reward"]
		. " " . $_POST["fractionToFail"]
		. " " . $_POST["minGoldAnswered"]
		. " " . $_POST["duration"] 
		. " " . $_POST["autoApprovalDelay"] 
		. " " . $_POST["lifetime"] 
		. " " . "\"" . $_POST["keywords"] . "\""
		. " " . $_POST["checkInterval"] 
		. " " . $_POST["idCol"] 
		. " " . $_POST["goldCol"] 
		. " " . $_POST["keys_of_selected"] 
		. " " . $_POST["keys_of_gold"] 
		. " " . $_POST["crowdHistoryFile"] 
		. " > /dev/null 2>/dev/null &");
	// string added to end to make php process execute asynchronously in background
	*/

	// TESTING GetParams.java
	// java [<option> ...] <class-name> [<argument> ...]
	$output = shell_exec("java GetParams"
		. " " .	$_POST["questionFile"] 
		. " " . $_POST["dataFile"] 
		. " " . "\"" . $_POST["title"] . "\""
		. " " . "\"" . $_POST["description"] . "\""
		. " " . $_POST["numAssignments"]
		. " " . $_POST["reward"]
		. " " . $_POST["fractionToFail"]
		. " " . $_POST["minGoldAnswered"]
		. " " . $_POST["duration"] 
		. " " . $_POST["autoApprovalDelay"] 
		. " " . $_POST["lifetime"] 
		. " " . "\"" . $_POST["keywords"] . "\""
		. " " . $_POST["checkInterval"] 
		. " " . $_POST["idCol"] 
		. " " . $_POST["goldCol"] 
		. " " . $_POST["keys_of_selected"] 
		. " " . $_POST["keys_of_gold"] 
		. " 2>&1");
		echo "<pre>$output<pre>";
?>
<input type="button" value="See Crowd History" onclick="loadXMLDoc()">
<pre id="crowdHistory"></pre>
</body>
</html>
