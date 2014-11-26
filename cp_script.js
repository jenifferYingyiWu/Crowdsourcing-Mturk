$(document).ready(function() {
	var keys_of_selected = [];
	var numSelected = 0;
	var keys_of_gold = [];
	var numGold = 0;	
		
	// select/deselect a single row
	$('#data tbody').on('click', 'tr', function() {
		var ID = $(this).attr('id');
		// unselected --> selected
		if ($(this).hasClass('unselected')) {
			$(this).removeClass('unselected');
			$(this).addClass('selected');
			keys_of_selected.push(ID); 
		}
		else if ($(this).hasClass('selected')) {
			// selected --> gold
			if ($("input[name='usingGold']:checked").val() == 'true') {
				$(this).removeClass('selected');	
				$(this).addClass('gold');	
				keys_of_gold.push(ID);
			}
			// selected --> unselected
			else {
				$(this).removeClass('selected');	
				$(this).addClass('unselected');	
				var index = keys_of_selected.indexOf(ID);
				keys_of_selected.splice(index, 1);
			}
		}
		// gold --> unselected
		else {
			$(this).removeClass('gold');	
			$(this).addClass('unselected');	
			var index_gold = keys_of_gold.indexOf(ID);
			keys_of_gold.splice(index_gold, 1);
			var index_selected = keys_of_selected.indexOf(ID);
			keys_of_selected.splice(index_selected, 1);
		}
		updateCounts();
	});

	// basic pattern: 
	// change keys_of_selected and keys_of_gold 
	// to reflect the current state of the table
	// then call updateCounts.
	function updateCounts() 
	{
		numSelected = keys_of_selected.length;
		$("#numSelected").html(numSelected);	
		numGold = keys_of_gold.length;
		$("#numGold").html(numGold);	
	}

	function deselectRows() 
	{
		$('.selected').removeClass('selected');
		$('.gold').removeClass('gold');
		$('#data tbody tr').addClass('unselected');
		keys_of_selected = [];
		keys_of_gold = [];
		updateCounts();
	}

	// deselect all rows
	$('#deselectAll').click(deselectRows);

	$('#selectAll_nongold').click(function() {
		$('#data > tbody > tr').each(function() {
			if ($(this).css('display') != 'none') {
				if ($(this).hasClass('unselected')) {
					$(this).removeClass('unselected');
					$(this).addClass('selected');
					var ID = $(this).attr('id');
					keys_of_selected.push(ID);
				}
				if ($(this).hasClass('gold')) {
					$(this).removeClass('gold');
					$(this).addClass('selected');
					var ID = $(this).attr('id');
					var index = keys_of_gold.indexOf(ID);
					keys_of_gold.splice(index, 1);
				}
			}
		});
		updateCounts();
	});

	$('#selectAll_gold').click(function() {
		$('#data > tbody > tr').each(function() {
			if ($(this).css('display') != 'none') {
				var ID = $(this).attr('id');
				if ($(this).hasClass('unselected')) {
					$(this).removeClass('unselected');
					$(this).addClass('gold');
					keys_of_selected.push(ID);
					keys_of_gold.push(ID);
				}
				if ($(this).hasClass('selected')) {
					$(this).removeClass('selected');
					$(this).addClass('gold');
					keys_of_gold.push(ID);
				}
			}
		});
		updateCounts();
	});

	// on page load
	if ($("input[name='usingGold']:checked").val() == 'false') {
		$(".usingGold").css('display', 'none');
		$(".usingGoldRow").hide();
		$("#selectAll_gold").hide();
		$("select[name='tableOp'] option[value='selectAsGold']").hide();
		$("input[name='goldCol']").val('-1'); 
		$("input[name='minGoldAnswered']").val('-1'); 
	}

	$("input[name='rejectType']").change(function() {
		if ($("input[name='rejectType']:checked").val() == 'accuracy')
			$(".usingAccuracyReject").show();
		else // val == 'mistakes'
			$(".usingAccuracyReject").hide();
	});

	$("input[name='blockType']").change(function() {
		if ($("input[name='blockType']:checked").val() == 'accuracy')
			$(".usingAccuracyBlock").show();
		else // val == 'mistakes'
			$(".usingAccuracyBlock").hide();
	});

	$("input[name='usingGold']").change(function() {
		if ($("input[name='usingGold']:checked").val() == 'true') {
			$(".usingGold").css('display', 'inline-block');
			$(".usingGoldRow").show();
			$("#selectAll_gold").show();
			$("#selectAll_nongold").val('Select all as non gold');
			$("select[name='tableOp'] option[value='selectAsGold']").show();
			$("input[name='goldCol']").val(''); 
			$("input[name='minGoldAnswered']").val(''); 
			$("#tableRotations").html(
				"unselected &#8594; selected &#8594; gold &#8594; unselected.");
		}
		else {
			$(".usingGold").css('display', 'none');
			$(".usingGoldRow").hide();
			$("#selectAll_gold").hide();
			$("#selectAll_nongold").val('Select all');
			$("select[name='tableOp'] option[value='selectAsGold']").hide();
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

	$('#executeRandSelect').click(function() {
		var numRandSelected = parseInt($('#numRandSelected').val());
		var numSelectedAsGold = parseFloat($('#numSelectedAsGold').val());
		var visibleIds = [];
		var numVisible = $('#data > tbody > tr:visible').length;
		var usingGold = ($("input[name='usingGold']:checked").val() == 'true');
		if (numRandSelected < 0 || numRandSelected > numVisible
			|| (usingGold && (numSelectedAsGold < 0 || numSelectedAsGold > numRandSelected))) {
			alert("Invalid number of records to select.");
			$('#numRandSelected').val('');
			$('#numSelectedAsGold').val('');
			return;
		}
					
		deselectRows();

		$('#data > tbody > tr:visible').each(function() {
			var ID = $(this).attr('id');
			visibleIds.push(ID);
		});
		// randomly choose a subset of visibleIds to be selected (randIds).
		var randIds = [];
		for (var i = 0; i < numRandSelected; i++) {
			var randIndex = Math.floor(Math.random()*visibleIds.length);
			var randId = visibleIds.splice(randIndex, 1);	
			randIds.push(randId);
			var thisRow = $('#' + randId);
			thisRow.addClass('selected');
			thisRow.removeClass('unselected');
			keys_of_selected.push(randId);
		}

		if (usingGold) {
			// randomly choose a subset of the selected records (randIds) to be gold.
			for (var i = 0; i < numSelectedAsGold; i++) {
				var randIndex = Math.floor(Math.random()*randIds.length);
				var randId = randIds.splice(randIndex, 1);
				var thisRow = $('#' + randId);
				thisRow.addClass('gold');
				thisRow.removeClass('selected');
				keys_of_gold.push(randId);
			}
		}
		updateCounts();
	});

	$('#executeTableOp').click(function() {
		var op = $('select[name="tableOp"]').val()
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
					// ignore hidden rows
					if (that.css('display') != 'none') {
						if (op == 'filter' && $(this).html() != valToSearch) {
							// HIDE ROW since the value in colToSearch is not valToSearch
							var ID = that.attr('id');
							that.css('display', 'none');
							if (that.hasClass('selected')) {
								that.addClass('unselected');
								that.removeClass('selected');	
								var index = keys_of_selected.indexOf(ID);
								keys_of_selected.splice(index, 1);
							}
							if (that.hasClass('gold')) {
								that.addClass('unselected');
								that.removeClass('gold');
								var index_sel = keys_of_selected.indexOf(ID);
								keys_of_selected.splice(index_sel, 1);
								var index_gold = keys_of_gold.indexOf(ID);
								keys_of_gold.splice(index_gold, 1);
							}
						}
						else if (op == 'selectAsNonGold' && $(this).html() == valToSearch) {
							// SELECT ROW since the value in colToSearch is valToSearch
							var ID = that.attr('id');
							if (that.hasClass('unselected')) {
								that.removeClass('unselected');
								that.addClass('selected');
								keys_of_selected.push(ID);
							}
							if (that.hasClass('gold')) {
								that.removeClass('gold');
								that.addClass('selected');
								var index = keys_of_gold.indexOf(ID);
								keys_of_gold.splice(index, 1);
							}
						}
						else if (op == 'selectAsGold' && $(this).html() == valToSearch) {
							// SELECT ROWS AS GOLD since the value in colToSearch is valToSearch
							var ID = that.attr('id');
							if (that.hasClass('unselected')) {
								that.removeClass('unselected');
								that.addClass('gold');
								keys_of_selected.push(ID);
								keys_of_gold.push(ID);
							}
							if (that.hasClass('selected')) {
								that.removeClass('selected');
								that.addClass('gold');
								keys_of_gold.push(ID);
							}
						}
						else if (op == 'deselect' && $(this).html() == valToSearch) {
							// DESELECT ROWS AS GOLD since the value in colToSearch is valToSearch
							var ID = that.attr('id');
							if (that.hasClass('selected')) {
								that.removeClass('selected');
								that.addClass('unselected');
								var index = keys_of_selected.indexOf(ID);
								keys_of_selected.splice(index, 1);
							}
							if (that.hasClass('gold')) {
								that.removeClass('gold');
								that.addClass('unselected');
								var index_gold = keys_of_gold.indexOf(ID);
								keys_of_gold.splice(index_gold, 1);
								var index_selected = keys_of_selected.indexOf(ID);
								keys_of_selected.splice(index_selected, 1);
							}
						}
					}
				}
				i++;
			});
			updateCounts();
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
		selected_str = keys_of_selected.join(" ");
		gold_str = keys_of_gold.join(" ");
		// remove r's from ids.
		selected_str = selected_str.replace(/r/g, "");
		gold_str = gold_str.replace(/r/g, "");
		$('input[name=keys_of_selected]').val(selected_str);
		$('input[name=keys_of_gold]').val(gold_str);
	});
});
