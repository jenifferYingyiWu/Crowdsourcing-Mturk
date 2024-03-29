<?php
session_start();
if (!(isset($_SESSION['loggedin']) || $_SESSION['loggedin'] == true)) {
	header('Location: login.html');
	die();
}
?>
<!DOCTYPE html>
<html>
<head>
<title>Upload File</title>
<script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
</head>
<body>
<form action="collectParameters.php" method="POST" enctype="multipart/form-data">
<h3>Specify Data File</h3>
<ul>
<li>The file must be in CSV format.</li>
<li>The first line must contain the names of the columns.</li>
<li>One column must contain values which uniquely identify each record.</li>
<li>If image links are provided, they must be valid HTTP URLs.</li>
<li>If text may contain commas, it must be encapsulated with double quotes.</li>
</ul>
<p>Examples: <a href="examples/face10.details" target="_blank">Faces</a>, 
	<a href="examples/tweets50.details" target="_blank">Tweets</a></p>
Choose the data file:
<input type="file" name="dataFile">

<hr>

<h3>Specify Question Format File</h3>
<ul>
<li>The file is in <a target="_blank" href="http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_QuestionFormDataStructureArticle.html">QuestionForm format</a>.</li>
<li>Place ${columnName} within a field anywhere you would like it to be replaced
	by the contents of columnName in the actual task.</li>
<li>The <i>AnswerSpecification</i> field must contain the <i>SelectionAnswer</i> field.</li>
<li>For the <i>Selection</i> fields within the <i>SelectionAnswer</i> 
	field:</li>
	<ul>
		<li>The <i>Text</i> fields must contain the actual values for the labels.</li>
		<li>The <i>SelectionIdentifier</i> fields contain unique abbreviations
		representing these actual values.</li>
		<li><i>MinSelectionCount</i> and <i>MaxSelectionCount</i> must have a value of 1.</li>
	</ul>
</ul>
<p>Examples: <a href="examples/face10.question" target="_blank">Faces</a>, 
<a href="examples/tweets50.question" target="_blank">Tweets</a></p>
Choose the question format file:
<input type="file" name="questionFile">

<hr>

<input type="submit" value="Upload Files and Continue">
</form>
</body>
</html>
