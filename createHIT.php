<?php
	echo shell_exec("/opt/lampp/htdocs/mturk/createHIT.sh 2>&1");
	echo 'Successfully created HIT';
?>
