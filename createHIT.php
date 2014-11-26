<!DOCTYPE html>
<html>
<head>
<title>HIT Created</title>
<script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
<script type="text/javascript">
	function loadXMLDoc() {
		var numSelected = <?php echo json_encode(count(explode(",", $_POST["keys_of_selected"]))); ?>;
		var username = <?php echo json_encode($_POST['username']); ?>;
		var resultsFile = <?php echo json_encode($_POST['resultsFile']); ?>;

		var xmlhttp = new XMLHttpRequest();
		// add '?t='+Math.random() to prevent caching. Makes webserver realize
		// that we are loading a new (possibly updated) document each time.
		/*xmlhttp.open('GET', 'MTurkCrowdSourcing/history/csHistory?t=' + Math.random(), true);*/
		var pathToResults = 'users/' + username + '/results/' + resultsFile;
		xmlhttp.open('GET', pathToResults + '?t=' + Math.random(), true);

		xmlhttp.onload = function() {
			var responseText_split = (xmlhttp.responseText).split("\n");
			// only show reponses once the first timestamped results come in
			if (responseText_split.length > numSelected+2) {
				// accumulate lines by reading from start forwards until blank line
				var responseTextStart = "";
				var i = 0;
				while (responseText_split[i].length != 0) {
					if (responseText_split[i+1].length != 0) 
						responseTextStart = responseTextStart + ("<br>" + responseText_split[i]);
					else 
						responseTextStart = responseTextStart + ("<br><a target=\"_blank\" href=\"" 
							+ responseText_split[i] + "\">Preview HIT</a>"); 
					i++;
				}
				// accumulate lines by reading from end backwards until blank line
				var responseTextEnd = "";
				i = responseText_split.length-2;
				while (responseText_split[i].length != 0) {
					responseTextEnd = ("<br>" + responseText_split[i]) + responseTextEnd;
					i--;
				}
				var responseText = responseTextStart + "<br>" + responseTextEnd;
				document.getElementById('results').innerHTML = responseText;
			}
		}
		xmlhttp.send(null);
	}
</script>
<style>
a:visited { color: blue; }
</style>
</head>
<body>
<?php
	
	// After successfully moving the files, update the details file
	$output = shell_exec('python updateDetails.py'
		. ' ' . $_POST['username'] 
		. ' ' . $_POST['dataFile'] 
		. ' ' . $_POST["idCol"]
		. ' ' . $_POST["urlCol"]
		. ' ' . $_POST["goldCol"]
		. ' ' . $_POST["usingGold"]
		. ' ' . $_POST["questionFile"]
	);
	# echo "<pre>" . $output . "<pre>";
	# updateDetails("sam", "face10.details", "PrimaryKey", "publishedURL", "orientation", "face10.question")

	$json = array(
		'username' => $_POST["username"],
		'questionFile' => $_POST["questionFile"],
		'title' => $_POST["title"],
		'description' => $_POST["description"],
		'numAssignments' => $_POST["numAssignments"],
		'reward' => $_POST["reward"],
		'minGoldAnswered' => $_POST["minGoldAnswered"],
		'duration' => $_POST["duration"],
		'autoApprovalDelay' => $_POST["autoApprovalDelay"],
		'lifetime' => $_POST["lifetime"],
		'keywords' => $_POST["keywords"],
		'checkInterval' => $_POST["checkInterval"],
		'idCol' => $_POST["idCol"],
		'goldCol' => $_POST["goldCol"],
		'keys_of_selected' => $_POST["keys_of_selected"],
		'keys_of_gold' => $_POST["keys_of_gold"],
		'resultsFile' => $_POST["resultsFile"],
		'rejectType' => $_POST["rejectType"], /* accuracy or numMistakes */
		'blockType' => $_POST["blockType"], /* accuracy or numMistakes */
		'accuracy_reject' => $_POST["accuracy_reject"], 
		'numMistakes_reject' => $_POST["numMistakes_reject"], 		
		'accuracy_block' => $_POST["accuracy_block"], 
		'numMistakes_block' => $_POST["numMistakes_block"],
		'usingGold' => $_POST["usingGold"]
	);
	file_put_contents('users/' . $_POST["username"] . '/params/' 
		. $_POST["resultsFile"] . '.params', json_encode($json, JSON_PRETTY_PRINT));

	//$output = shell_exec("cd MTurkCrowdSourcing;
	//	java -cp \"external_jars/*:.\" mturkcrowdsourcing.MTurkCrowdSourcing
	//  . "> /dev/null 2>/dev/null &");
		//echo "<pre>$output<pre>";
	// string added to end to make php process execute asynchronously in background
?>
<input type="button" value="See Results So Far" onclick="loadXMLDoc()">
<div id="results"></div><br>
<a href="home.php">Go Home</a>
</body>
</html>
