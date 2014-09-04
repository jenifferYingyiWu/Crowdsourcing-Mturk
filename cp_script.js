$(document).ready(function() {
	var keys_of_selected = [];
	var numSelected = 0;
	var keys_of_gold = [];
	var numGold = 0;
		
	// select/deselect a single row
	$('#data tbody').on('click', 'tr', function() {
		var ID = parseInt($(this).find('td:first-child').html());
		// unselected --> selected
		if ($(this).hasClass('unselected')) {
			$(this).removeClass('unselected');
			$(this).addClass('selected');
			keys_of_selected.push(ID); 
			numSelected++;
		}
		else if ($(this).hasClass('selected')) {
			// selected --> gold
			if ($("input[name='usingGold']:checked").val() == 'true') {
				$(this).removeClass('selected');	
				$(this).addClass('gold');	
				keys_of_gold.push(ID);
				numGold++;
			}
			// selected --> unselected
			else {
				$(this).removeClass('selected');	
				$(this).addClass('unselected');	
				var index = keys_of_selected.indexOf(ID);
				keys_of_selected.splice(index, 1);
				numSelected--;
			}
		}
		// gold --> unselected
		else {
			$(this).removeClass('gold');	
			$(this).addClass('unselected');	
			var index_gold = keys_of_gold.indexOf(ID);
			keys_of_gold.splice(index_gold, 1);
			numGold--;
			var index_selected = keys_of_selected.indexOf(ID);
			keys_of_selected.splice(index_selected, 1);
			numSelected--;
		}

		$("#numSelected").html(numSelected);	
		$("#numGold").html(numGold);	
	});

	// deselect all rows
	$('#deselectAll').click(function() {
		$('.selected').removeClass('selected');
		$('.gold').removeClass('gold');
		$('#data tbody tr').addClass('unselected');
		keys_of_selected = [];
		numSelected = 0;
		keys_of_gold = [];
		numGold = 0;
		$("#numSelected").html(numSelected);	
		$("#numGold").html(numGold);	
	});

	// select all rows
	$('#selectAll').click(function() {
		$('.unselected').addClass('selected');
		$('.unselected').removeClass('unselected');
		keys_of_selected = [];
		for (var i = 1; i <= numRecords; i++)
			keys_of_selected.push(i);
		numSelected = numRecords;
		$("#numSelected").html(numSelected);	
		$("#numGold").html(numGold);	
	});

	// on page load
	if ($("input[name='usingGold']:checked").val() == 'false') {
		$(".usingGold").css('display', 'none');
		$(".usingGoldRow").hide();
		$("input[name='goldCol']").val('-1'); 
		$("input[name='minGoldAnswered']").val('-1'); 
	}

	$("input[name='usingGold']").change(function() {
		if ($("input[name='usingGold']:checked").val() == 'true') {
			$(".usingGold").css('display', 'block');
			$(".usingGoldRow").show();
			$("input[name='goldCol']").val(''); 
			$("input[name='minGoldAnswered']").val(''); 
			$("#tableRotations").html(
				"unselected &#8594; selected &#8594; gold &#8594; unselected.");
		}
		else {
			$(".usingGold").css('display', 'none');
			$(".usingGoldRow").hide();
			// dummy vals for java command line arguments
			$("input[name='goldCol']").val('-1'); 
			$("input[name='minGoldAnswered']").val('-1'); 
			$("#tableRotations").html("unselected &#8594; selected &#8594; unselected.");

			// if we first selected 'usingGold' and selected some gold data, 
			// but then changed to not 'usingGold', we must change all gold data to simply selected.
			$(".gold").addClass('selected');
			$(".gold").removeClass('gold');
			keys_of_gold = [];
			numGold = 0;
			$("#numGold").html(numGold);	
		}
	});

	// on submitting the form, set the value of the hidden input in the form
	$("#hit_form").submit(function() {
		$('input[name=keys_of_selected]').val(keys_of_selected.join(","));

		if ($("input[name='usingGold']:checked").val() == 'true')
			$('input[name=keys_of_gold]').val(keys_of_gold.join(","));
		else 
			$('input[name=keys_of_gold]').val("-1"); // dummy val for java command line arguments
	});
});
