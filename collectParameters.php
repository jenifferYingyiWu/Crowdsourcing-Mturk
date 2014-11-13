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
session_start();
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

<h2>Specify Task Parameters</h2>

<form action="createHIT.php" method="post" id="hit_form" class="bottom-margin">

<b>Title</b><br>
A short description of what this task entails.<br> 
The title appears in the search results and everywhere the task is mentioned.<br>
<input class="text" type="text" name="title"><br><br>
<b>Description</b><br>
A general description giving detailed information about what this task entails.<br>
The description appears in the expanded view of search results, and task assignment screen.<br>
<input class="text" type="text" name="description"><br><br>
<b>Keywords</b><br>
One or more words or phrases that describe the task.<br>
Must be separated by commas.<br>
<input class="text" type="text" name="keywords"><br><br>
<b>Number of Assignments</b><br>
Number of labels collected for each selected record.<br>
Must be an odd number.<br>
<input class="numeric" type="text" name="numAssignments"><br><br>
<b>Reward</b><br>
Amount of money (in $) paid to a worker for labeling one record.<br>
Minimum value of 0.01. Value must be in increments of 0.01.<br>
<input class="numeric" type="text" name="reward"><br><br>
<b>Duration</b><br>
Amount of time (in seconds) a worker has to complete the task after accepting it.<br>
<input class="numeric" type="text" name="duration"><br><br>
<b>Auto Approval Delay</b><br>
Amount of time (in seconds) after submitting the task that it will be automatically approved.<br>
<input class="numeric" type="text" name="autoApprovalDelay"><br><br>
<b>Lifetime</b><br>
Amount of time (in seconds) after which the task is no longer available for workers to accept.<br>
<input class="numeric" type="text" name="lifetime"><br><br>
<b>Check Interval</b><br>
How frequently (in milliseconds) the interface should request the current results of the crowdsourcing.<br>
Recommended: 5000ms (5s).<br>
<input class="numeric" type="text" name="checkInterval"><br><br>
<b>Unique Column</b><br>
The name of a column containing values which uniquely identify each record.<br>
<input class="singleName" type="text" name="idCol"><br><br>
<b>Project Name</b><br>
A name for you to reference the results of this crowdsourcing project in the future.<br>
<input class="singleName" type="text" name="resultsFile"><br><br>

<hr>

<p>To make sure we are only collecting data from and paying workers who submit
data of a high enough quality:</p>

<table border="0" id="middleTable">
<tr>
	<td>Reject a worker if:</td>
	<td>
		<input name="rejectType" type="radio" value="accuracy" checked>Accuracy &lt;
		<input class="numeric" type="text" name="accuracy_reject"> %<br>
		<input name="rejectType" type="radio" value="numMistakes"># of Mistakes &gt;
		<input class="numeric" type="text" name="numMistakes_reject"><br>
	</td>
	<td class="usingAccuracyReject">Accuracy calculated after at least 
	<input class="numeric" name="questionsForAccuracy_reject"> questions.</td>
</tr>
<tr>
	<td>Block a worker if:</td>
	<td>
		<input name="blockType" type="radio" value="accuracy" checked>Accuracy &lt;
		<input class="numeric" type="text" name="accuracy_block"> %<br>
		<input name="blockType" type="radio" value="numMistakes"># of Mistakes &gt;
		<input class="numeric" type="text" name="numMistakes_block"><br>
	</td>
	<td class="usingAccuracyBlock">Accuracy calculated after at least 
	<input class="numeric" name="questionsForAccuracy_block"> questions.</td>
</tr>
</table>

<p>Workers' labels should be checked against:</p>
<input type="radio" name="usingGold" value="false" checked>
The majority votes of the labels from other workers.<br>
<input type="radio" name="usingGold" value="true" id="lastUsingGold">
Gold labels, provided by you.<br>

<p class="usingGoldRow">Reject worker if number of gold questions answered is less than
	<input class="usingGoldRow numeric" type="text" name="minGoldAnswered">
</p>
<p class="usingGoldRow">Name of column with gold labels:
	<input class="usingGoldRow singleName" type="text" name="goldCol">
</p>

<hr>
<p>Number of records selected: <span id="numSelected">0</span></p>
<div class="usingGold">
Number of records used as gold data: <span id="numGold">0</span><br>
</div>
<p><input id="selectAll_nongold" type="button" value="Select all">
<input id="selectAll_gold" type="button" value="Select all as gold">
<input id="deselectAll" type="button" value="Deselect all">
<input id="resetRecords" type="button" value="Reset Records"></p>

<select name="tableOp">
<option value="filter">Filter</option>
<option value="selectAsNonGold">Select as non gold</option>
<option value="selectAsGold">Select as gold</option>
<option value="deselect">Deselect</option>
</select>
records where column <input type="text" id="colToSearch" class="singleName">
has value <input type="text" id="valToSearch" class="singleName">
<input id="executeTableOp" type="button" value="Execute"><br><br>

<div class="inline">Randomly select 
<input type="text" class="numeric" id="numRandSelected"> records
</div>
<div class="inline usingGold"> where 
<input type="text" class="numeric" id="numSelectedAsGold">
selected records are treated as gold records</div>
<input id="executeRandSelect" type="button" value="Execute"><br>

<p> Clicking a table row cycles through 
<span id="tableRotations">unselected &#8594; selected &#8594; unselected.</span></p>

<?php
$handle = fopen($dataFileDest, "r");
$columnNames = fgetcsv($handle); // get first line
$columnNames = array_map('trim', $columnNames);
$numCols = count($columnNames);

echo "<table id=\"data\" border=\"1\">";
echo "<thead><tr>";
for ($i = 0; $i < $numCols; $i++)
	echo "<th align=\"left\">" . $columnNames[$i] . "</th>";
echo "</tr></thead><tbody>";

$valid_image_types = array('jpg', 'gif', 'png');
$numRecords = 0;

while ($line = fgetcsv($handle)) {
	$line = array_map('trim', $line);
	echo "<tr id='r" . $numRecords . "' class='unselected'>";
	for ($i = 0; $i < $numCols; $i++) {
		echo "<td>";
		if (filter_var($line[$i], FILTER_VALIDATE_URL)) {
			$path_parts = pathinfo($line[$i]);
			if (in_array($path_parts['extension'], $valid_image_types))
				echo "<image src=\"" . $line[$i] . "\" style=\"max-height: 40px\">";	
			else
				echo $line[$i];	
		}
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
<input type="hidden" name="username" value="<?php echo $_SESSION['username']; ?>">

<!-- values changed in js file upon submit -->
<input type="hidden" name="keys_of_selected"> 
<input type="hidden" name="keys_of_gold">

<input type="submit" value="Submit">
</form>

<script type="text/javascript">
// transfer php variables to javascript so they can be used in cp_script.js
var numRecords = <?php echo json_encode($numRecords); ?>; // total number of records
var columnNames = <?php echo json_encode($columnNames); ?>;
</script>

</body>
</html>
