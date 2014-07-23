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

<form action="createHIT.php" method="post" class="bottom-margin">
<label>Title:</label> <input type="text" name="title"><br>
<label>Description:</label>	<textarea rows="3" cols="35" name="description"></textarea><br>
<label>Number of assignments:</label> <input type="text" name="numAssignments"><br>
<label>Reward:</label> <input type="text" name="reward"><br>
<label>Percentage failed to reject:</label> <input type="text" name="percentFailed"><br>
<input type="submit" value="Submit">
</form>

Number of tweets selected: <span id="numSelected">0</span><br>
Positive: <span id="numPositive">0</span><br>
Negative: <span id="numNegative">0</span><br>
<input id="selectAll" type="button" value="Select all">
<input id="deselectAll" type="button" value="Deselect all">

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
}
echo "</tbody></table>";
fclose($handle);

?> 
</body>
</html>
