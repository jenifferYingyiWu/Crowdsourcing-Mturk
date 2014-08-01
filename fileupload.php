<!DOCTYPE html>
<html>
<head>
	<title>File uploaded</title>
	<link rel="stylesheet" type="text/css" href="style.css">
	<script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
	<script src="chooseTweet.js" type="text/javascript"></script>
	<meta charset="utf-8">
</head>
<body>
<?php
// if there was an error opening the file
if ($_FILES["myFile"]["error"] > 0) {
	echo "Error: " . $_FILES["myFile"]["error"] . "<br />";
	exit;
}

// else, print file details
echo "Upload: " . $_FILES["myFile"]["name"] . "<br>";
//echo "Type: " . $_FILES["myFile"]["type"] . "<br>";
//echo "Temp file: " . $_FILES["myFile"]["tmp_name"]. "<br>";

// move the file to its permanent location
$upload_dir = "/opt/lampp/htdocs/mturk/uploads/";
$fileDest = $upload_dir . $_FILES["myFile"]["name"];

$success = move_uploaded_file($_FILES["myFile"]["tmp_name"], $fileDest);
if (!$success) {
	echo "<p>Unable to save file.</p>";
	exit;
}

chmod($fileDest, 0644);
echo "Stored in: " . rtrim($upload_dir, "/") . "<br>";
echo "Size: " . round($_FILES["myFile"]["size"] / 1024,4) . " Kb<br><br>";
?>

<form action="createHIT.php" method="post" id="hit_form" class="bottom-margin">
<label>Title:</label> 
<input type="text" name="title"><br>
<label>Description:</label>	
<input type="text" name="description"><br>
<label>Number of assignments:</label> 
<input type="text" name="numAssignments"><br>
<label>Reward:</label> 
<input type="text" name="reward"><br>
<label>Percentage failed to reject:</label> 
<input type="text" name="percentFailed"><br>
<label>Minimum batch size:</label>
<input type="text" name="minBatchSize"><br>
<label>Duration of HIT (sec):</label>
<input type="text" name="HITduration"><br>
<input type="hidden" name="tweetIDs" /> <!-- value changed in js file upon submit -->
<input type="hidden" name="uploadedFile" value="<?php echo $_FILES["myFile"]["name"]; ?>" />
<input type="submit" value="Submit">
</form>

Number of tweets selected: <span id="currSelected">0</span><br>
Positive: <span id="currPositive">0</span><br>
Negative: <span id="currNegative">0</span><br><br>
<input id="selectAll" type="button" value="Select all">
<input id="deselectAll" type="button" value="Deselect all"><br>

<?php
// read the data set row by row,
// where each row takes the form: ID,sentiment,text
$ID = array();
$sentiment = array();
$text = array();

// and output the dataset in a table
echo "<table id=\"data\" border=\"1\">";
echo "<thead><tr>";
echo "<th align=\"left\">ID</th>";
echo "<th align=\"left\">Sentiment</th>";
echo "<th align=\"left\">Text</th>";
echo "</tr></thead><tbody>";

$numTweets = 0;
$numPositive = 0;
$numNegative = 0;

$handle = fopen($fileDest, "r");
while (($row = fgets($handle)) !== false) {
	$parts = explode(",", $row);	

	$currID = $parts[0];
	array_push($ID, $currID);
	$currSentiment = $parts[1];
	array_push($sentiment, $currSentiment);

	// get rid of first 2 elts (ID and sentiment). Only text remains.
	$parts_onlyText = array_slice($parts, 2); 
	// put text back together incase it had commas and was exploded.
	$currText = implode(",", $parts_onlyText);
	array_push($text, $currText);

	echo "<tr><td>" . $currID . "</td>";
	echo "<td>" . $currSentiment . "</td>";
	echo "<td>" . $currText . "</td></tr>";

	$numTweets = $numTweets + 1;
	if ($currSentiment == 0)
		$numNegative = $numNegative + 1;
	else 
		$numPositive = $numPositive + 1;
}

echo "</tbody></table>";
fclose($handle);
?> 

<script type="text/javascript">
// transfer php variables to javascript so they can be used in chooseTweet.js
// These are used for selectAll / deselectAll buttons
var numTweets = <?php echo json_encode($numTweets); ?>;		// total number of tweets
var numPositive = <?php echo json_encode($numPositive); ?>; // total number of pos tweets
var numNegative = <?php echo json_encode($numNegative); ?>; // total number of neg tweets
</script>

</body>
</html>
