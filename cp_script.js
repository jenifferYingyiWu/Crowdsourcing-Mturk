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

	function deselectRows() 
	{
		$('.selected').removeClass('selected');
		$('.gold').removeClass('gold');
		$('#data tbody tr').addClass('unselected');
		keys_of_selected = [];
		numSelected = 0;
		keys_of_gold = [];
		numGold = 0;
		$("#numSelected").html(numSelected);	
		$("#numGold").html(numGold);	
	}

	// deselect all rows
	$('#deselectAll').click(deselectRows);

	// select all rows
	$('#selectAll').click(function() {
		$('.unselected').addClass('selected');
		$('.unselected').removeClass('unselected');
		keys_of_selected = [];
		var i = 1;
		$('#data > tbody > tr').each(function() {
			if ($(this).css('display') != 'none')
				keys_of_selected.push(i);
			i++;
		});
		numSelected = keys_of_selected.length;
		$("#numSelected").html(numSelected);	
	});

	// on page load
	if ($("input[name='usingGold']:checked").val() == 'false') {
		$(".usingGold").css('display', 'none');
		$(".usingGoldRow").hide();
		$("input[name='goldCol']").val('-1'); 
		$("input[name='minGoldAnswered']").val('-1'); 
	}

	$("input[name='rejectType']").change(function() {
		if ($("input[name='rejectType']:checked").val() == 'accuracy') {
			$(".usingAccuracyReject").show();
			$("input[name='goldCol']").val(''); 
		}
		else { // val == 'mistakes'
			$(".usingAccuracyReject").hide();
			$("input[name='goldCol']").val('-1'); 
		}
	});

	$("input[name='blockType']").change(function() {
		if ($("input[name='blockType']:checked").val() == 'accuracy') {
			$(".usingAccuracyBlock").show();
			$("input[name='goldCol']").val(''); 
		}
		else { // val == 'mistakes'
			$(".usingAccuracyBlock").hide();
			$("input[name='goldCol']").val('-1'); 
		}
	});

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

	$('#getRecords').click(function() {
		var colToSearch = $('#colToSearch').val();
		var valToSearch = $('#valToSearch').val();
		if (columnNames.indexOf(colToSearch) == -1) {
			alert('Invalid Column Name: ' + colToSearch);
			$('#colToSearch').val('');
			return;
		}

		$('#data > tbody > tr').each(function() {
			var i = 0;
			var that = $(this);
			$(this).find('td').each(function() {
				if (columnNames[i] == colToSearch) {
					if (that.css('display') != 'none') { // ignore hidden rows
						// hide rows where the value in colToSearch is not valToSearch
						if ($(this).html() != valToSearch) {
							that.css('display', 'none'); // hide row
							if (that.hasClass('selected')) {
								numSelected--;
								$("#numSelected").html(numSelected);	
							}
							if (that.hasClass('gold')) {
								numSelected--;
								numGold--;
								$("#numSelected").html(numSelected);	
								$("#numGold").html(numGold);	
							}
						}
					}
				}
				i++;
			});
		});	
		$('#colToSearch').val('');
		$('#valToSearch').val('');
	});

	$('#resetRecords').click(function() {
		$('#data > tbody > tr').css('display', '');	
		deselectRows();	
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
