var tweetIDs = [];

$(document).ready(function() {
	// select/deselect a single row
	$('#data tbody').on('click', 'tr', function() {
		var ID = $(this).find('td:first-child').html();
		if ($(this).hasClass('selected')) {
			$(this).removeClass('selected');	
			var index = tweetIDs.indexOf(ID);
			tweetIDs.splice(index, 1);
		}
		else {
			$(this).addClass('selected');
			tweetIDs.push(ID);
		}
		//alert(tweetIDs.join(" "));
	});

	// deselect all rows
	$('#deselectAll').click(function() {
		$('.selected').removeClass('selected');	
		tweetIDs = [];
	});

	// select all rows
	$('#selectAll').click(function() {
		$('#data tbody tr').addClass('selected');	
		tweetIDs = [];
		for (var i = 1; i <= document.getElementById("data").rows.length-1; i++)
			tweetIDs.push(i);
	});
});
