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
<input type="hidden" name="keys_of_selected"> <!-- value changed in js file upon submit -->
<input type="hidden" name="uploadedFile" value="<?php echo $_FILES["myFile"]["name"]; ?>">
<input type="submit" value="Submit">
</form>

Number of records selected: <span id="numSelected">0</span><br>
<input id="selectAll" type="button" value="Select all">
<input id="deselectAll" type="button" value="Deselect all"><br>

<?php
// read the data set row by row,
// where each row takes the form: ID,sentiment,text
// and output the dataset in a table
$ID = array();
$sentiment = array();
$text = array();

$numTweets = 0;
$numPositive = 0;
$numNegative = 0;

$handle = fopen($fileDest, "r");
$firstLine = fgetcsv($handle);
$numCols = count($firstLine);

echo "<table id=\"data\" border=\"1\">";
echo "<thead><tr>";
for ($i = 0; $i < $numCols; $i++)
	echo "<th align=\"left\">" . $firstLine[$i] . "</th>";
echo "</tr></thead><tbody>";

$numRecords = 0;
while ($line = fgetcsv($handle)) {
	echo "<tr>";
	for ($i = 0; $i < $numCols; $i++)
		echo "<td>" . $line[$i] . "</td>";
	echo "</tr>";
	$numRecords++;
}
echo "</tbody></table>";
fclose($handle);
?> 

<script type="text/javascript">
// transfer php variables to javascript so they can be used in chooseTweet.js
var numRecords = <?php echo json_encode($numRecords); ?>; // total number of records
</script>

</body>
</html>
