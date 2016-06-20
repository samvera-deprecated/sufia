export class RelationshipsTable {

  // Initializes the class in the context of an individual table element
  constructor(element) {
    this.$element = element;
    this.add_url = this.$element.data('api-add-url');
    this.remove_url = this.$element.data('api-remove-url');
    this.works_context = this.$element.data('works-context');

    // TODO: Fall back to just cloning rows and removing rows if there are no
    // urls or works_context
    if (!this.add_url || !this.remove_url || !this.works_context)
      return;

    this.bindAddButton();
    this.bindRemoveButton();
    this.bindKeyEvents();
  }

  // Handle click events by the "Add" button in the table, setting a warning
  // message if the input is empty or calling the API to handle the request
  bindAddButton() {
    let $this = this;

    $this.$element.on("click", ".btn-add-row", function(event) {
      let $row = $(this).parents("tr:first");
      let $input = $row.find("input.new-form-control");
      let on_error = $this.handleError;
      let on_success = $this.handleAddRowSuccess;
      let url = $this.add_url;

      // Display an error when the input field is empty, otherwise clone the
      // row and set appropriate styles
      if ($input.val() == "") {
        $this.setWarningMessage($row, "ID cannot be empty.");
      } else {
        // reset warning to hidden before cloning
        $row.find(".message.has-warning").addClass("hidden");
        $this.callAPI({
          row: $row,
          input: $input,
          url: url,
          on_error: on_error,
          on_success: on_success
        });
      }
    });
  }

  // Handle click events by the "Remove" buttons in the table, and calling the
  // API to handle the request
  bindRemoveButton() {
    let $this = this;

    $this.$element.on("click", ".btn-remove-row", function(event) {
      let $row = $(this).parents("tr:first");
      let $input = $row.find("input.related_works_ids:first");
      let on_error = $this.handleError;
      let on_success = $this.handleRemoveRowSuccess;
      let url = $this.remove_url;

      $this.callAPI({
        row: $row,
        input: $input,
        url: url,
        on_error: on_error,
        on_success: on_success
      });
    });
  }

  // Handle keyup and keypress events a the form level to prevent the ENTER key
  // from submitting the form. ENTER key within a relationships table should
  // click the "Add" button instead. ESC key should clear the input and hide the
  // error message.
  bindKeyEvents() {
    let $form = this.$element.parents("form");

    $form.on("keyup keypress", "input.related_works_ids", function(event) {
      let $row = $(this).parents("tr:first");
      let key_code = event.keyCode || event.which;

      // ENTER key was pressed, wait for keyup to click the Add button
      if (key_code === 13) {
        if (event.type == "keyup") {
          $row.find(".btn-add-row").click();
        }
        event.preventDefault();
        return false;
      }

      // ESC key was pressed, clear the input field and hide the error
      if(key_code === 27 && event.type == "keyup"){
        $(this).val("");
        $row.find(".message").addClass("hidden");
      }
    });
  }

  // Set the warning message related to the appropriate row in the table
  setWarningMessage($row, message) {
    $row.find(".message.has-warning").text(message).removeClass("hidden");
  }

  // Clone an existing row, inserting it immediately before the passed in row,
  // and set the clone and original row to appropriate state
  cloneRow($row) {
    let $table = $row.parents("table:first");
    let $clone = $row.clone();
    $clone.find(".btn-add-row").addClass("hidden");
    $clone.find(".btn-remove-row").removeClass("hidden");
    $clone.insertBefore($row);

    // finally, empty the "add" row input value
    $row.find("input.new-form-control").val("");
    return $clone;
  }

  // Call the API, then call the appropriate callbacks to handle success and
  // errors
  callAPI(args) {
    let $this = this;
    let url = args.url.replace(':id', args.input.val());
    $.getJSON(url)
      .done(function(json) {
        args.on_success($this, args.row, json);
      })
      .fail(function(jqxhr, status, err) {
        args.on_error($this, args.row, jqxhr);
      });
  }

  // Set a warning message to alert the user on an API error
  handleError($this, $row, jqxhr) {
    $this.setWarningMessage($row, jqxhr.responseText);
  }

  // Remove the row when the API returns this type of success
  handleRemoveRowSuccess($this, $row, json) {
    $row.remove();
  }

  // Add a new row and set its details relative to the data-works-context
  // specified by the table related to this instance of the RelationshipsTable
  // class. This gives the ability to handle parent and child type rows
  // dynamically
  handleAddRowSuccess($this, $row, json) {
    let $clone = $this.cloneRow($row);
    let $title = $clone.find("a.title:first");
    let $edit = $clone.find("a.edit:first");
    let $input = $clone.find("input.related_works_ids:first");
    let key = $this.works_context.toLowerCase();
    let title = json[key].title[0];
    let href = json[key].path;
    let id = json[key].id;

    // Set the cloned input to have the proper name and value for posting the
    // form to the server, and hide it.
    $input.removeClass("new-form-control")
      .addClass("hidden")
      .val(id);

    // Set the linkified title and show.
    $title.text(title);
    $title.attr("href", href);
    $title.removeClass("hidden");

    // Set the edit button link and show.
    $edit.attr("href", href + "/edit");
    $edit.removeClass("hidden");
  }
}
