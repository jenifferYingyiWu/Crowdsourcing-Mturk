$(document).ready(function() {
	var keys_of_selected = [];
	var numSelected = 0;
	
	// select/deselect a single row
	$('#data tbody').on('click', 'tr', function() {
		var ID = parseInt($(this).find('td:first-child').html());
		var sentiment = $(this).find('td:nth-child(2)').html();

		if ($(this).hasClass('selected')) {
			$(this).removeClass('selected');	
			var index = keys_of_selected.indexOf(ID);
			keys_of_selected.splice(index, 1);
			numSelected -= 1;
		}
		else {
			$(this).addClass('selected');
			keys_of_selected.push(ID); numSelected += 1;
		}
		document.getElementById("numSelected").innerHTML = numSelected;	
	});

	// deselect all rows
	$('#deselectAll').click(function() {
		$('.selected').removeClass('selected');
		keys_of_selected = [];
		numSelected = 0;
		document.getElementById("numSelected").innerHTML = numSelected;	
	});

	// select all rows
	$('#selectAll').click(function() {
		$('#data tbody tr').addClass('selected');
		keys_of_selected = [];
		for (var i = 1; i <= numRecords; i++)
			keys_of_selected.push(i);
		numSelected = numRecords;
		document.getElementById("numSelected").innerHTML = numSelected;	
	});

	// on submitting the form, set the value of the hidden input in the form
	$("#hit_form").submit(function() {
		$('input[name=keys_of_selected]').val(keys_of_selected.join(","));
	});
});
