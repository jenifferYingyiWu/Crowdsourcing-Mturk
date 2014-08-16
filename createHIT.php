<!DOCTYPE html>
<html>
<head>
<title>HIT Created</title>
<script type="text/javascript">
	function loadXMLDoc() {
		var crowdHistoryFile = <?php echo json_encode($_POST["crowdHistoryFile"]); ?>;
		var numSelected = <?php echo json_encode(count(explode(",",$_POST["keys_of_selected"]))); ?>;
		var xmlhttp = new XMLHttpRequest();
		// add '?t='+Math.random() to prevent caching. Makes webserver realize
		// that we are loading a new (possibly updated) document each time.
		xmlhttp.open('GET', 'MTurkCrowdSourcing/history/' + crowdHistoryFile + '?t=' + Math.random(), true);

		xmlhttp.onload = function() {
			/*
			var responseText_split = (xmlhttp.responseText).split("\n");

			// accumulate lines by reading from start forwards until blank line
			var responseTextStart = "";
			var i = 0;
			while (responseText_split[i] != "" && i != responseText_split.length) {
				if (responseText_split[i+1] != "") 
					responseTextStart = responseTextStart + ("<br>" + responseText_split[i]);
				else 
					responseTextStart = responseTextStart + ("<br><a target=\"_blank\" href=\"" 
						+ responseText_split[i] + "\">Preview HIT</a>"); 
				i++;
			}

			// accumulate lines by reading from end backwards until blank line
			var responseTextEnd = "";
			i = responseText_split.length-2;
			while (responseText_split[i] != "" || i != -1) {
				responseTextEnd = ("<br>" + responseText_split[i]) + responseTextEnd;
				i--;
			}
			var responseText = responseTextStart + "<br>" + responseTextEnd;
			document.getElementById('crowdHistory').innerHTML = responseText;
			*/
			document.getElementById('crowdHistory').innerHTML = xmlhttp.responseText;
		}
		xmlhttp.send(null);
	}
</script>
</head>
<body>
<?php
	exec("cd MTurkCrowdSourcing; java -cp \"external_jars/*:.\" mturkcrowdsourcing.MTurkCrowdSourcing"
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
		. "> /dev/null 2>/dev/null &");
	// string added to end to make php process execute asynchronously in background

	/*
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
	*/
?>
<input type="button" value="See Crowd History" onclick="loadXMLDoc()">
<div id="crowdHistory"></div>
</body>
</html>
