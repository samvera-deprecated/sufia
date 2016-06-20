// Once, javascript is written in a modular format, all initialization
// code should be called from here.
Sufia = {
    initialize: function () {
        this.saveWorkControl();
        this.saveWorkFixed();
        this.popovers();
        this.permissions();
        this.notifications();
        this.transfers();
        this.relationships_table();
    },

    saveWorkControl: function () {
        var sw = require('sufia/save_work/save_work_control');
        new sw.SaveWorkControl($("#form-progress")).activate();
    },

    saveWorkFixed: function () {
        // Setting test to false to skip native and go right to polyfill
        FixedSticky.tests.sticky = false;
        $('#savewidget').fixedsticky();
    },

    // initialize popover helpers
    popovers: function () {
        $("a[data-toggle=popover]").popover({html: true})
            .click(function () {
                return false;
            });
    },

    permissions: function () {
        var perm = require('sufia/permissions/control');
        new perm.PermissionsControl($("#share"), 'generic_work', 'tmpl-work-grant');
        new perm.PermissionsControl($("#permission"), 'file_set', 'tmpl-file-set-grant');
    },

    notifications: function () {
        var note = require('sufia/notifications');
        $('[data-update-poll-url]').each(function () {
            var interval = $(this).data('update-poll-interval');
            var url = $(this).data('update-poll-url');
            new note.Notifications(url, interval);
        });
    },

    transfers: function () {
        $("#proxy_deposit_request_transfer_to").userSearch();
    },

    relationships_table: function () {
        var rel = require('sufia/relationships_table');
        $('table.relationships-api-enabled').each(function () {
            var add_url = $(this).data('api-add-url');
            var remove_url = $(this).data('api-remove-url');
            var works_context = $(this).data('works-context');
            new rel.RelationshipsTable($(this));
        });
    }
};

Blacklight.onLoad(function () {
    Sufia.initialize();
});
