/*
 * Copyright 2011-2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class AlertViewView : Gtk.Grid {
    construct {
        var alert = new Granite.Widgets.AlertView (
            "Nothing here",
            "Maybe you can enable <b>something</b> to hide it but <i>otherwise</i> it will stay here",
            "dialog-warning"
        );
        alert.show_action ("Hide this button");

        alert.action_activated.connect (() => {
            alert.hide_action ();
        });

        add (alert);
    }
}
