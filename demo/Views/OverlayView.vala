/*
 * Copyright 2017-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class OverlayBarView : DemoPage {
    construct {
        var picture = new Gtk.Picture.for_filename ("/usr/share/backgrounds/elementaryos-default") {
            content_fit = COVER,
            margin_top = 12,
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12
        };
        picture.add_css_class (Granite.CssClass.CARD);

        var toast = new Granite.Toast (_("Button was pressed!"));
        toast.set_default_action (_("Do Things"));

        var toast_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            halign = CENTER,
            tooltip_text = "Send Toast"
        };
        toast_button.add_css_class (Granite.CssClass.OSD);

        var spinner_button = new Gtk.ToggleButton.with_label ("Show Spinner");
        spinner_button.add_css_class (Granite.CssClass.OSD);

        var box = new Granite.Box (HORIZONTAL) {
            halign = CENTER,
            valign = CENTER
        };
        box.append (spinner_button);
        box.append (toast_button);

        var overlay = new Gtk.Overlay () {
            child = picture,
            hexpand = true
        };
        overlay.add_overlay (box);
        overlay.add_overlay (toast);
        overlay.set_measure_overlay (toast, true);

        var overlaybar = new Granite.OverlayBar (overlay) {
            label = "Hover the OverlayBar to change its position"
        };

        child = overlay;

        toast_button.clicked.connect (toast.send_notification);

        toast.default_action.connect (() => {
            toast.title = _("Already did the thing");
            toast.set_default_action (null);
        });

        spinner_button.bind_property ("active", overlaybar, "active");
    }
}
