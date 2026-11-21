/*
 * Copyright 2011-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ToastOverlayView : Gtk.Box {
    private Granite.NotifyToastOverlay toast_overlay;

    construct {
        var button = new Gtk.Button.with_label (_("Press Me")) {
            halign = START
        };

        var basic_box = new Gtk.Box (VERTICAL, 12);
        basic_box.append (new Granite.HeaderLabel (_("Basic")));
        basic_box.append (button);

        var top_left_button = new Gtk.Button.with_label (_("Top Left"));
        var bottom_left_button = new Gtk.Button.with_label (_("Bottom Left"));
        var bottom_right_button = new Gtk.Button.with_label (_("Bottom Right"));

        var position_button_box = new Gtk.Box (HORIZONTAL, 6) {
            halign = START
        };
        position_button_box.append (top_left_button);
        position_button_box.append (bottom_left_button);
        position_button_box.append (bottom_right_button);

        var position_box = new Gtk.Box (VERTICAL, 12);
        position_box.append (new Granite.HeaderLabel (_("Position")) {
            secondary_text = _("Location of the toast is customized with the position property. Valid values are 'top-left', 'top-center', 'top-right', 'bottom-left', 'bottom-center' and 'bottom-right'")
        });
        position_box.append (position_button_box);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24) {
            margin_start = 24,
            margin_end = 24,
            margin_top = 24,
            margin_bottom = 24
        };
        
        box.append (basic_box);
        box.append (position_box);

        toast_overlay = new Granite.NotifyToastOverlay () {
            child = box
        };

        append (toast_overlay);

        button.clicked.connect (() => {
            send_toast (_("Button was pressed!"));
        });

        top_left_button.clicked.connect (() => {
            send_toast (_("Top Left"), Granite.NotifyToastPosition.TOP_LEFT);
        });

        bottom_left_button.clicked.connect (() => {
            send_toast (_("Bottom Left"), Granite.NotifyToastPosition.BOTTOM_LEFT);
        });

        bottom_right_button.clicked.connect (() => {
            send_toast (_("Bottom Right"), Granite.NotifyToastPosition.BOTTOM_RIGHT);
        });
    }

    private void send_toast (string title, Granite.NotifyToastPosition position = Granite.NotifyToastPosition.TOP_CENTER) {
        var toast = new Granite.NotifyToast (title) {
            position = position
        };
            
        toast_overlay.add_toast (toast);
    }
}
