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
echo "Size: " . round($_FILES["myFile"]["size"] / 1024,4) . " Kb<br>";
?>

<h3>Specify HIT Parameters</h3>

<form action="createHIT.php" method="post" id="hit_form" class="bottom-margin">
<label class="topLabel">Title:</label> 
<input type="text" name="title"><br>
<label class="topLabel">Description:</label>	
<input type="text" name="description"><br>
<label class="topLabel">Labels Per Record:</label> 
<input type="text" name="labelsPerRecord"><br>
<label class="topLabel">Reward ($):</label> 
<input type="text" name="reward"><br>
<label class="topLabel">Duration (seconds):</label>
<input type="text" name="HITduration"><br><br>

To verify a user is submitting good data:<br>
<input type="radio" name="usingGold" value="false" checked>Use all selected records 
with the crowd's majority vote as labels.<br>
<input type="radio" name="usingGold" value="true">Use a subset 
of the selected records as gold data. Labels must available.<br><br>

<label class="botLabel">Reject if classification accuracy on above 
selected data is less than:</label>
<input type="text" name="rejectionThreshold"><br>

<div class="usingGold">
<label class="botLabel">Proportion of gold data randomly chosen to attach to each group:</label>
<input type="text" name="percentOfGold"><br>
<label class="botLabel">Name of column with the labels:</label>
<input type="text" name="labelCol"><br>
</div>

<label class="botLabel">Comma separated list of possible values for the labels:</label> 
<input type="text" name="labelValues"><br><br>

<!-- values changed in js file upon submit -->
<input type="hidden" name="keys_of_selected"> 
<input type="hidden" name="keys_of_gold">

<input type="hidden" name="uploadedFile" value="<?php echo $_FILES["myFile"]["name"]; ?>">
<input type="submit" value="Submit">
</form>

Number of records selected: <span id="numSelected">0</span><br>
<div class="usingGold">
Number of records used as gold data: <span id="numGold">0</span><br>
</div>
<input id="selectAll" type="button" value="Select all">
<input id="deselectAll" type="button" value="Deselect all"><br>
Clicking a table row cycles through 
<span id="tableRotations">unselected &#8594; selected &#8594; unselected.</span><br>

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
$columnNames = fgetcsv($handle); // get first line
$numCols = count($columnNames);
$columnNames = array_map('trim', $columnNames);

echo "<table id=\"data\" border=\"1\">";
echo "<thead><tr>";
for ($i = 0; $i < $numCols; $i++)
	echo "<th align=\"left\">" . $columnNames[$i] . "</th>";
echo "</tr></thead><tbody>";

if (isset($_POST['imageCols']))
	$imageCols = explode(",", $_POST['imageCols']);
else
	$imageCols = array("-1");

$numRecords = 0;
while ($line = fgetcsv($handle)) {
	$line = array_map('trim', $line);
	echo "<tr class='unselected'>";
	for ($i = 0; $i < $numCols; $i++) {
		echo "<td>";
		if (in_array($columnNames[$i], $imageCols))
			echo "<image src=\"" . $line[$i] . "\">";	
		else 
			echo $line[$i];	
		echo "</td>";
	}
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
