/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class AsyncImageView : Gtk.Grid {
    private Gtk.FlowBox flow_box;

    construct {
        flow_box = new Gtk.FlowBox ();

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.expand = true;
        scrolled.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        scrolled.add (flow_box);

        var load_button = new Gtk.Button.with_label ("Load Applications Icons");
        load_button.clicked.connect (() => load_icons.begin ());
        load_button.margin = 6;
        load_button.halign = Gtk.Align.END;

        attach (scrolled, 0, 0, 1, 1);
        attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 1, 1);
        attach (load_button, 0, 2, 1, 1);
    }

    private async void load_icons () {
        flow_box.get_children ().@foreach ((child) => {
            child.destroy ();
        });

        var icons = new Gee.ArrayList<string> ();

        var icon_theme = Gtk.IconTheme.get_default ();
        icon_theme.list_icons ("Applications").@foreach ((name) => {
            icons.add (name);
        });

        foreach (string name in icons) {
            var image = new Granite.AsyncImage.from_icon_name_async (name, Gtk.IconSize.DIALOG);
            flow_box.add (image);
            flow_box.show_all ();
        }
    }
}
