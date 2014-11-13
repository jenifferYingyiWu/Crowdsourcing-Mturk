<!DOCTYPE html>
<html>
<head>
	<title>Specify Task Parameters</title>
	<link rel="stylesheet" type="text/css" href="cp_style.css">
	<script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
	<script src="cp_script.js" type="text/javascript"></script>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
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

<form role="form" action="createHIT.php" method="post" id="hit_form" class="bottom-margin">

<div class="form-group">
<label>Title</label><br>
A short description of what this task entails.<br> 
The title appears in the search results and everywhere the task is mentioned.<br>
<input class="text form-control" type="text" name="title">
</div>

<div class="form-group">
<label>Description</label><br>
A general description giving detailed information about what this task entails.<br>
The description appears in the expanded view of search results, and task assignment screen.<br>
<input class="text form-control" type="text" name="description">
</div>

<div class="form-group">
<label>Keywords</label><br>
One or more words or phrases that describe the task.<br>
Must be separated by commas.<br>
<input class="text form-control" type="text" name="keywords">
</div>

<div class="form-group">
<label>Number of Assignments</label><br>
Number of labels collected for each selected record.<br>
Must be an odd number.<br>
<input class="numeric form-control" type="text" name="numAssignments">
</div>

<div class="form-group">
<label>Reward</label><br>
Amount of money (in $) paid to a worker for labeling one record.<br>
Minimum value of 0.01. Value must be in increments of 0.01.<br>
<input class="numeric form-control" type="text" name="reward">
</div>

<div class="form-group">
<label>Duration</label><br>
Amount of time (in seconds) a worker has to complete the task after accepting it.<br>
<input class="numeric form-control" type="text" name="duration">
</div>

<div class="form-group">
<label>Auto Approval Delay</label><br>
Amount of time (in seconds) after submitting the task that it will be automatically approved.<br>
<input class="numeric form-control" type="text" name="autoApprovalDelay">
</div>

<div class="form-group">
<label>Lifetime</label><br>
Amount of time (in seconds) after which the task is no longer available for workers to accept.<br>
<input class="numeric form-control" type="text" name="lifetime">
</div>

<div class="form-group">
<label>Check Interval</label><br>
How frequently (in milliseconds) the interface should request the current results of the crowdsourcing.<br>
Recommended: 5000ms (5s).<br>
<input class="numeric form-control" type="text" name="checkInterval">
</div>

<div class="form-group">
<label>Unique Column</label><br>
The name of a column containing values which uniquely identify each record.<br>
<input class="singleName form-control" type="text" name="idCol">
</div>

<div class="form-group">
<label>Project Name</label><br>
A name for you to reference the results of this crowdsourcing project in the future.<br>
<input class="singleName form-control" type="text" name="resultsFile">
</div>

<hr>

<p>To make sure we are only collecting data from and paying workers who submit
data of a high enough quality:</p>

<div id="reject_input">
	<label class="floatLeft">Reject a worker if:</label>
	<div class="floatLeft">
		<input name="rejectType" type="radio" value="accuracy" checked>Accuracy &lt;
		<input class="numeric" type="text" name="accuracy_reject"> %<br>
		<input name="rejectType" type="radio" value="numMistakes"># of Mistakes &gt;
		<input class="numeric" type="text" name="numMistakes_reject"><br>
	</div>
	<div class="usingAccuracyReject floatLeft">
		Accuracy calculated after at least 
		<input class="numeric" name="questionsForAccuracy_reject"> questions.
	</div>
</div>

<br><br>
<br><br>

<div id="block_input">
	<label class="floatLeft">Block a worker if:</label>
	<div class="floatLeft">
		<input name="blockType" type="radio" value="accuracy" checked>Accuracy &lt;
		<input class="numeric" type="text" name="accuracy_block"> %<br>
		<input name="blockType" type="radio" value="numMistakes"># of Mistakes &gt;
		<input class="numeric" type="text" name="numMistakes_block"><br>
	</div>
	<div class="usingAccuracyBlock floatLeft">
		Accuracy calculated after at least 
		<input class="numeric" name="questionsForAccuracy_block"> questions.
	</div>
</div>

<br><br>
<br><br>

<p>Workers' labels should be checked against:</p>
<input type="radio" name="usingGold" value="false" checked>
The majority votes of the labels from other workers.<br>
<input type="radio" name="usingGold" value="true" id="lastUsingGold">
Gold labels, provided by you.<br>

<p class="usingGoldRow">Reject worker if number of gold questions answered is less than
	<input class="usingGoldRow numeric form-control" type="text" name="minGoldAnswered">
</p>
<p class="usingGoldRow">Name of column with gold labels:
	<input class="usingGoldRow singleName form-control" type="text" name="goldCol">
</p>

<hr>

<p>Number of records selected: <span id="numSelected">0</span></p>
<div class="usingGold">
Number of records used as gold data: <span id="numGold">0</span>
</div><br>
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
records where column <input type="text" id="colToSearch" class="singleName form-control">
has value <input type="text" id="valToSearch" class="singleName form-control">
<input id="executeTableOp" type="button" value="Execute"><br><br>

Randomly select <input type="text" class="numeric" id="numRandSelected"> records
<span class="usingGold"> 
where <input type="text" class="numeric" id="numSelectedAsGold">
of the selected records are treated as gold records
</span>
<input id="executeRandSelect" type="button" value="Execute"><br><br>

<p> Clicking a table row cycles through 
<span id="tableRotations">unselected &#8594; selected &#8594; unselected.</span></p>

<?php
$handle = fopen($dataFileDest, "r");
$columnNames = fgetcsv($handle); // get first line
$columnNames = array_map('trim', $columnNames);
$numCols = count($columnNames);

echo "<table id='data' border='1' class='table table-bordered'>";
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
