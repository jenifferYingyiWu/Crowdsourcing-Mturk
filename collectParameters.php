<!DOCTYPE html>
<html>
<head>
	<title>Specify Task Parameters</title>
	<link rel="stylesheet" type="text/css" href="cp_style.css">
	<script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
	<script src="cp_script.js" type="text/javascript"></script>
	<meta charset="utf-8">
</head>
<body>
<?php
// if there was an error opening the files
if ($_FILES["dataFile"]["error"] > 0) {
	echo "Error: " . $_FILES["dataFile"]["error"] . "<br>";
	exit;
}
if ($_FILES["questionFile"]["error"] > 0) {
	echo "Error: " . $_FILES["dataFile"]["error"] . "<br>";
	exit;
}

// move the file to its permanent location
$upload_dir = "/opt/lampp/htdocs/mturk/uploads/";
$dataFileDest = $upload_dir . $_FILES["dataFile"]["name"];
$questionFileDest = $upload_dir . $_FILES["questionFile"]["name"];

$success = move_uploaded_file($_FILES["dataFile"]["tmp_name"], $dataFileDest);
if (!$success) {
	echo "<p>Unable to save data file.</p>";
	exit;
}
chmod($dataFileDest, 0644);

$success = move_uploaded_file($_FILES["questionFile"]["tmp_name"], $questionFileDest);
if (!$success) {
	echo "<p>Unable to save question file.</p>";
	exit;
}
chmod($questionFileDest, 0644);

// print file details
/*
echo "<b>Data File</b><br>";
echo "Location: " . $dataFileDest . "<br>";
echo "Size: " . round($_FILES["dataFile"]["size"] / 1024,4) . " Kb<br>";
echo "<b>Question File</b><br>";
echo "Location: " . $questionFileDest . "<br>";
echo "Size: " . round($_FILES["questionFile"]["size"] / 1024,4) . " Kb<br>";
*/
?>

<h3>Specify Task Parameters</h3>

<form action="createHIT.php" method="post" id="hit_form" class="bottom-margin">

<table border="0" id="topTable">
<tr><td>Title:</td> 
	<td><input class="text" type="text" name="title"></td></tr>
<tr><td>Description:</td> 
	<td><input class="text" type="text" name="description"></td></tr>
<tr><td>Keywords:</td> 
	<td><input class="text" type="text" name="keywords"></td></tr>
<tr><td>Number of Assignments:</td> 
	<td><input class="numeric" type="text" name="numAssignments"></td></tr>
<tr><td>Reward ($):</td> 
	<td><input class="numeric" type="text" name="reward"></td></tr>
<tr><td>Duration (seconds):</td> 
	<td><input class="numeric" type="text" name="duration"></td></tr>
<tr><td>Auto Approval Delay (seconds):</td> 
	<td><input class="numeric" type="text" name="autoApprovalDelay"></td></tr>
<tr><td>Lifetime (seconds):</td>
	<td><input class="numeric" type="text" name="lifetime"></td></tr>
<tr><td>Check Interval (milliseconds):</td>
	<td><input class="numeric" type="text" name="checkInterval"></td></tr>
<tr><td>Name of column with primary keys:</td>
	<td><input type="text" name="idCol"></td></tr>
<tr><td>Name of file to store results:</td>
	<td><input type="text" name="resultsFile"></td></tr>
</table>
<div class="bottom-margin"></div>

<b>To verify a worker has submitted data of a high enough quality:</b><br>
<input type="radio" name="usingGold" value="false" checked>Use all selected records 
with the crowd's majority vote as labels.<br>
<input type="radio" name="usingGold" value="true" id="lastUsingGold">Use a subset 
of the selected records as gold data. Gold labels must available.<br>

<table border="0" id="middleTable">
<tr><td>Reject worker if accuracy on above selected data is less than:</td>
	<td><input class="numeric" type="text" name="fractionToFail"></td></tr>
<tr class="usingGoldRow"><td>Reject worker if number of gold questions answered is less than:</td>
	<td><input class="numeric" type="text" name="minGoldAnswered"></td></tr>
<tr class="usingGoldRow"><td>Name of column with gold labels:</td>
	<td><input type="text" name="goldCol"></td></tr>
</table>
<div class="bottom-margin"></div>

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

$handle = fopen($dataFileDest, "r");
$columnNames = fgetcsv($handle); // get first line
$numCols = count($columnNames);
$columnNames = array_map('trim', $columnNames);

echo "<table id=\"data\" border=\"1\">";
echo "<thead><tr>";
for ($i = 0; $i < $numCols; $i++)
	echo "<th align=\"left\">" . $columnNames[$i] . "</th>";
echo "</tr></thead><tbody>";

$imageCols = explode(",", $_POST['imageCols']);

$numRecords = 0;
while ($line = fgetcsv($handle)) {
	$line = array_map('trim', $line);
	echo "<tr class='unselected'>";
	for ($i = 0; $i < $numCols; $i++) {
		echo "<td>";
		if (in_array($columnNames[$i], $imageCols))
			echo "<image src=\"" . $line[$i] . "\" style=\"max-height: 40px\">";	
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

<input type="hidden" name="dataFile" value="<?php echo $_FILES["dataFile"]["name"]; ?>">
<input type="hidden" name="questionFile" value="<?php echo $_FILES["questionFile"]["name"]; ?>">

<!-- values changed in js file upon submit -->
<input type="hidden" name="keys_of_selected"> 
<input type="hidden" name="keys_of_gold">

<input type="submit" value="Submit">
</form>

<script type="text/javascript">
// transfer php variables to javascript so they can be used in chooseTweet.js
var numRecords = <?php echo json_encode($numRecords); ?>; // total number of records
</script>

</body>
</html>
