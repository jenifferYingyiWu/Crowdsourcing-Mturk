$(document).ready(function() {
	var tweetIDs = [];
	var currSelected = 0;
	var currPositive = 0;
	var currNegative = 0;
	
	// select/deselect a single row
	$('#data tbody').on('click', 'tr', function() {
		var ID = $(this).find('td:first-child').html();
		var sentiment = $(this).find('td:nth-child(2)').html();
		if ($(this).hasClass('selected')) {
			$(this).removeClass('selected');	
			var index = tweetIDs.indexOf(ID);
			tweetIDs.splice(index, 1);
			currSelected -= 1;

			if (sentiment == 0)
				currNegative -= 1;	
			else
				currPositive -= 1;
		}
		else {
			$(this).addClass('selected');
			tweetIDs.push(ID);
			currSelected += 1;

			if (sentiment == 0)
				currNegative += 1;	
			else
				currPositive += 1;
		}

		document.getElementById("currSelected").innerHTML = currSelected;	
		document.getElementById("currPositive").innerHTML = currPositive;	
		document.getElementById("currNegative").innerHTML = currNegative;	
	});

	// deselect all rows
	$('#deselectAll').click(function() {
		$('.selected').removeClass('selected');

		tweetIDs = [];
		currSelected = 0;
		currPositive = 0;
		currNegative = 0;

		document.getElementById("currSelected").innerHTML = currSelected;	
		document.getElementById("currPositive").innerHTML = currPositive;	
		document.getElementById("currNegative").innerHTML = currNegative;	
	});

	// select all rows
	$('#selectAll').click(function() {
		$('#data tbody tr').addClass('selected');

		tweetIDs = [];
		for (var i = 1; i <= numTweets; i++)
			tweetIDs.push(i);

		currSelected = numTweets;
		currPositive = numPositive;
		currNegative = numNegative;

		document.getElementById("currSelected").innerHTML = currSelected;	
		document.getElementById("currPositive").innerHTML = currPositive;	
		document.getElementById("currNegative").innerHTML = currNegative;	
	});

	// on submitting the form, set the value of the hidden input in the form
	$("#hit_form").submit(function() {
		$('input[name=tweetIDs]').val(tweetIDs.join(","));
	});
});
