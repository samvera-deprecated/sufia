// Once, javascript is written in a modular format, all initialization
// code should be called from here.
Sufia = {
  initialize: function() {
    this.save_work_control();
    this.popovers();
    this.browse_everything();
  },

  browse_everything: function() {
    $('#browse-btn').browseEverything({
      onSelection: function(data) {
        $('#status').html(data.length.toString() + " <%= t('sufia.upload.browse_everything.files_selected')%>");
        $('#submit-btn').html("Submit "+data.length.toString() + " selected files");
        var evt = {
          isDefaultPrevented: function() { return false; }
        };
        var files = $.map(data, function(d) { return { name: d.file_name, size: d.file_size, id: d.url }; });

        $.blueimp.fileupload.prototype.options.done.call(
          $('#fileupload').fileupload(),
          evt,
          { result: { files: files }}
        );
      }});
  },

  save_work_control: function() {
    var sw = require('sufia/save_work/save_work_control');
    new sw.SaveWorkControl($("#form-progress")).activate();
  },

  // initialize popover helpers
  popovers: function() {
    $("a[data-toggle=popover]").popover({ html: true })
				 .click(function() { return false; });
  }
};

Blacklight.onLoad(function() {
  // Note the implementation of onLoad
  // takes care of turbolinks page change
  // detection, so neither our initializers
  // nor our libraries need to handle those.
  Sufia.initialize();
});
