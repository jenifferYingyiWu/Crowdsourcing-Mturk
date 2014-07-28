$(document).ready(function() {
	var tweetIDs = [];
	var currSelected = 0;
	var currPositive = 0;
	var currNegative = 0;
	
	// select/deselect a single row
	$('#data tbody').on('click', 'tr', function() {
		var ID = parseInt($(this).find('td:first-child').html());
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

	// In input fields:
	// Make text disappear when focused if it's the placeholder
	// Make text reappear when blurred if nothing is entered.
	var placeholders = {
		title: "Sentiment Analysis",
		description: "Determine the sentiment of each tweet.",
		numAssignments: "9",
		reward: "0.05",
		percentFailed: "0.8"
	};

	$("input").focus(function() {
		if ($(this).val() == placeholders[$(this).attr('name')]) 
			$(this).val('');
	});
	$("input").blur(function() {
		if ($(this).val() == '')
			$(this).val(placeholders[$(this).attr('name')]);
	});

	// on load, set the default values for all input fields except submit/hidden ones.
	$("form input:not(input[type='submit']):not(input[type='hidden'])").each(function() {
		$(this).val(placeholders[$(this).attr('name')]);
	});
});
