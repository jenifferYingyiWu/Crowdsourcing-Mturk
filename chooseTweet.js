$(document).ready(function() {
	var tweetIDs = [];
	var numSelected = 0;
	var numPositive = 0;
	var numNegative = 0;

	// select/deselect a single row
	$('#data tbody').on('click', 'tr', function() {
		var ID = $(this).find('td:first-child').html();
		var sentiment = $(this).find('td:nth-child(2)').html();
		if ($(this).hasClass('selected')) {
			$(this).removeClass('selected');	
			var index = tweetIDs.indexOf(ID);
			tweetIDs.splice(index, 1);
			numSelected -= 1;

			if (sentiment == 0)
				numNegative -= 1;	
			else
				numPositive -= 1;
		}
		else {
			$(this).addClass('selected');
			tweetIDs.push(ID);
			numSelected += 1;

			if (sentiment == 0)
				numNegative += 1;	
			else
				numPositive += 1;
		}

		document.getElementById("numSelected").innerHTML = numSelected;	
		document.getElementById("numPositive").innerHTML = numPositive;	
		document.getElementById("numNegative").innerHTML = numNegative;	

		//alert(tweetIDs.join(" "));
	});

	// deselect all rows
	$('#deselectAll').click(function() {
		// loop through all selected elements
		$('.selected').each(function() {
			$(this).removeClass('selected');	
		});

		tweetIDs = [];
		numSelected = 0;
		numPositive = 0;
		numNegative = 0;

		document.getElementById("numSelected").innerHTML = numSelected;	
		document.getElementById("numPositive").innerHTML = numPositive;	
		document.getElementById("numNegative").innerHTML = numNegative;	
	});

	// select all rows
	$('#selectAll').click(function() {
		tweetIDs = [];
		numSelected = 0;
		numPositive = 0;
		numNegative = 0;
		$('#data tbody tr').each(function(index) {
			$(this).addClass('selected');
			var sentiment = $(this).find('td:nth-child(2)').html();
			alert(sentiment);
			if (sentiment == 0)
				numNegative += 1;	
			else
				numPositive += 1;
			numSelected += 1;
			tweetIDs.push(index+1);
		});

		document.getElementById("numSelected").innerHTML = numSelected;	
		document.getElementById("numPositive").innerHTML = numPositive;	
		document.getElementById("numNegative").innerHTML = numNegative;	
	});
});
