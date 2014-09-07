<?php
	session_start();
	copy('MTurkCrowdSourcing/history/csHistory', 
		'users/' . $_SESSION['username'] . '/' . $_SESSION['resultsFile']);
?>
