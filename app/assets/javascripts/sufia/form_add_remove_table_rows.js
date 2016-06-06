$(document).ready(function() {

  // Add an empty new row to the table to take input for a new ID, when the form is posted
  // to the server a new relationship will be established.
  $(document).on("click", ".btn-add-row", function(event) {
    var api_call = $(this).data('api-call');
    var api_success = $(this).data('api-success');
    var api_error = $(this).data('api-error');
    var api_url = $(this).data('api-url');

    var $row = $(this).parents("tr:first");
    var $input = $row.find("input.new-form-control:first");

    // Display an error when the input field is empty, otherwise clone the row and set appropriate styles
    if ($input.val() == "") {
      setWarningMessage($row, "ID cannot be empty.");
    } else {
      // reset warning to hidden before cloning
      $row.find(".message.has-warning").addClass("hidden");

      if (api_call) {
        window[api_call]({url: api_url, input: $input, row: $row, success: api_success, error: api_error});
      } else {
        cloneRow($row);
      }
    }
  });

  // Remove the row from the table, when the form is posted to the server,
  // this ID will not be included, and the relationship will be severed.
  $(document).on("click", ".btn-remove-row", function(event) {
    var $row = $(this).parents("tr:first");
    var api_call = $(this).data('api-call');
    var api_success = $(this).data('api-success');
    var api_error = $(this).data('api-error');
    var api_url = $(this).data('api-url');
    var $input = $row.find("input.related_works_ids:first");
    if (api_call) {
      window[api_call]({url: api_url, input: $input, row: $row, success: api_success, error: api_error});
    } else {
      $row.remove();
    }
  });

  // Treat enter key as a click to the "add" button, prevent form from being
  // posted. Trigger add button click on keyup so that it's not repeated on
  // every keypress fired.
  $(document).on("keyup keypress", "form input.related_works_ids", function(event) {
    var $row = $(this).parents("tr:first");
    var key_code = event.keyCode || event.which;
    if(key_code === 13){
      if(event.type == "keyup") {
        $row.find(".btn-add-row").click();
      }
      event.preventDefault();
      return false;
    }
  });

  // If a new row has been added, and the input field is emptied,
  // then display the warning div. This isn't strictly necessary since the
  // add/remove buttons perform API calls now.
  /*
  $(document).on("keyup", "input.related_works_ids", function(event) {
    var $row = $(this).parents("tr:first");
    if ($(this).val().length == 0 && $(this).hasClass("new-form-control") == false) {
      setWarningMessage($row, "ID cannot be empty.");
    } else {
      $row.find(".message.has-warning").addClass("hidden");
    }
  });
  */
});

// Clone a row, insertting the just above the original. The cloned row
// represents the new row that has some modification such as it being the new
// parent/child work, while the original row remains to be the "new work" form
// used for adding a new parent/child.
var cloneRow = function($row) {
  var $table = $row.parents("table:first");
  var $clone = $row.clone();
  $clone.find(".btn-add-row").addClass("hidden");
  $clone.find(".btn-remove-row").removeClass("hidden");
  $clone.insertBefore($row);

  // finally, empty the "add" new row input value
  $row.find("input.new-form-control").val("");
  return $clone;
}

// Set the warning message div text and show it.
var setWarningMessage = function($row, message) {
  $row.find(".message.has-warning").text(message).removeClass("hidden");
}

// Call the api and perform the appropriate js callbacks
var apiCall = function(args) {
  var id = $(args.input).val();
  $.getJSON(args.url.replace(':id', id))
    .done(function(json) {
      window[args.success](args.row, json);
    })
    .fail(function(jqxhr, textStatus, err) {
      window[args.error](args.row, jqxhr);
    });
}

// PARENT works relationships
// ------------------------------------------------------------
// Adding parent succeeded, clone the form row then adjust the new parent row
// styles and elements to display details
var apiAddParentSuccess = function(row, json) {
  var clone = cloneRow($(row));
  var $title = $(clone).find("a.title:first");
  var $edit = $(clone).find("a.edit:first");
  var $input = $(clone).find("input.related_works_ids:first");

  // Hide the input to display the linkified parent works title. Set the input
  // name to ensure it's passed back to the server if the form is posted and set
  // the value to that of the parent work.
  $input.removeClass("new-form-control")
        .addClass("hidden")
        .attr("name", "generic_work[in_works_ids][]")
        .val(json.parent.id);

  // Set the linkified parent title and show it.
  $title.text(json.parent.title[0]);
  $title.attr("href", json.parent.path);
  $title.removeClass("hidden");

  // Set the edit button link and show it.
  $edit.attr("href", json.parent.path + "/edit");
  $edit.removeClass("hidden");
  console.log("apiAddParentSuccess:", json);
}

// Adding parent failed, display the proper alert message
var apiAddParentError = function(row, jqxhr) {
  setWarningMessage($(row), jqxhr.responseText);
  console.log("apiAddParentError:", jqxhr);
}

// Removing parent succeeded, remove the row from the table
var apiRemoveParentSuccess = function(row, json) {
  $(row).remove();
  console.log("apiRemoveParentSuccess:", json);
}

// Removing parent failed, display the proper alert message
var apiRemoveParentError = function(row, jqxhr) {
  setWarningMessage($(row), jqxhr.responseText);
  console.log("apiRemoveParentError:", jqxhr);
}
// ----------------------------------------------------------
// CHILD works relationships
// ------------------------------------------------------------
// Adding child succeeded, clone the form row then adjust the new child row
// styles and elements to display details
var apiAddChildSuccess = function(row, json) {
  var clone = cloneRow($(row));
  var $title = $(clone).find("a.title:first");
  var $edit = $(clone).find("a.edit:first");
  var $input = $(clone).find("input.related_works_ids:first");

  // Hide the input to display the linkified child works title. Set the input
  // name to ensure it's passed back to the server if the form is posted and set
  // the value to that of the child work.
  $input.removeClass("new-form-control")
        .addClass("hidden")
        .val(json.child.id);

  // Set the linkified child title and show it.
  $title.text(json.child.title[0]);
  $title.attr("href", json.child.path);
  $title.removeClass("hidden");

  // Set the edit button link and show it.
  $edit.attr("href", json.child.path + "/edit");
  $edit.removeClass("hidden");
  console.log("apiAddChildSuccess:", json);
}

// Adding child failed, display the proper alert message
var apiAddChildError = function(row, jqxhr) {
  setWarningMessage($(row), jqxhr.responseText);
  console.log("apiAddChildError:", jqxhr);
}

// Removing child succeeded, remove the row from the table
var apiRemoveChildSuccess = function(row, json) {
  $(row).remove();
  console.log("apiRemoveChildSuccess:", json);
}

// Removing child failed, display the proper alert message
var apiRemoveChildError = function(row, jqxhr) {
  setWarningMessage($(row), jqxhr.responseText);
  console.log("apiRemoveChildError:", jqxhr);
}
// ----------------------------------------------------------
