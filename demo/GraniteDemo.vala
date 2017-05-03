// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2011-2015 Granite Developers (https://launchpad.net/granite)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Lucas Baudin <xapantu@gmail.com>
 *              Jaap Broekhuizen <jaapz.b@gmail.com>
 *              Victor Eduardo <victoreduardm@gmal.com>
 *              Tom Beckmann <tom@elementary.io>
 *              Corentin Noël <corentin@elementary.io>
 */

public class Granite.Demo : Granite.Application {
    Gtk.Window window;
    Gtk.Paned main_paned;
    Gtk.Stack main_stack;
    Gtk.Button home_button;

    /**
     * Basic app information for Granite.Application. This is used by the About dialog.
     */
    construct {
        application_id = "org.pantheon.granite.demo";
        flags = ApplicationFlags.FLAGS_NONE;

        program_name = "Granite Demo";
        app_years = "2011-2016";

        build_version = "0.4.0.1";
        app_icon = "applications-interfacedesign";
        main_url = "https://launchpad.net/granite";
        bug_url = "https://bugs.launchpad.net/granite";
        help_url = "https://answers.launchpad.net/granite";
        translate_url = "https://translations.launchpad.net/granite";

        about_documenters = { null };
        about_artists = { "Daniel Foré <daniel@elementary.io>" };
        about_authors = {
            "Maxwell Barvian <mbarvian@gmail.com>",
            "Daniel Foré <daniel@elementary.io>",
            "Avi Romanoff <aviromanoff@gmail.com>",
            "Lucas Baudin <xapantu@gmail.com>",
            "Victor Eduardo <victoreduardm@gmail.com>",
            "Tom Beckmann <tombeckmann@online.de>",
            "Corentin Noël <corentin@elementary.io>"
        };

        about_comments = "A demo of the Granite toolkit";
        about_translators = _("translator-credits");
        about_license_type = Gtk.License.GPL_3_0;
    }

    public override void activate () {
        window = new Gtk.Window ();
        window.window_position = Gtk.WindowPosition.CENTER;
        add_window (window);

        main_stack = new Gtk.Stack ();
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        main_paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        create_headerbar ();
        create_welcome ();
        create_sourcelist ();
        create_toast ();
        create_modebutton ();
        create_dynamictab ();
        create_alert ();
        create_storage ();

        var date_time_picker_view = new DateTimePickerView ();

        main_stack.add_named (date_time_picker_view, "pickers");

        window.add (main_stack);
        window.set_default_size (800, 550);
        window.show_all ();
        home_button.hide ();
    }

    private void create_headerbar () {
        var headerbar = new Gtk.HeaderBar ();
        headerbar.title = "Granite";
        headerbar.subtitle = "Demo Window";
        headerbar.show_close_button = true;

        var about_button = new Gtk.Button.from_icon_name ("dialog-information", Gtk.IconSize.LARGE_TOOLBAR);
        about_button.tooltip_text = "About this application";
        about_button.clicked.connect (() => {show_about (window);});

        home_button = new Gtk.Button.with_label ("Back");
        home_button.get_style_context ().add_class ("back-button");
        home_button.valign = Gtk.Align.CENTER;
        home_button.clicked.connect (() => {
            main_stack.set_visible_child_name ("welcome");
            home_button.hide ();
        });

        var avatar = create_avatar ();

        var primary_color_button = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });
        primary_color_button.color_set.connect (() => {
            Granite.Widgets.Utils.set_color_primary (window, primary_color_button.rgba);
        });

        headerbar.pack_start (home_button);
        headerbar.pack_end (about_button);
        headerbar.pack_end (avatar);
        headerbar.pack_end (primary_color_button);
        window.set_titlebar (headerbar);
    }

    private void create_welcome () {
        var welcome = new Granite.Widgets.Welcome ("Sample Window", "This is a demo of the Granite library.");
        welcome.append ("office-calendar", "TimePicker & DatePicker", "Widgets that allows users to easily pick a time or a date.");
        welcome.append ("tag-new", "SourceList", "A widget that can display a list of items organized in categories.");
        welcome.append ("object-inverse", "ModeButton", "This widget is a multiple option modal switch");
        welcome.append ("document-open", "DynamicNotebook", "Tab bar widget designed for a variable number of tabs.");
        welcome.append ("dialog-warning", "AlertView", "A View showing that an action is required to function.");
        welcome.append ("drive-harddisk", "Storage", "Small bar indicating the remaining amount of space.");
        welcome.append ("dialog-information", _("Toasts"), _("Simple in-app notifications"));
        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    home_button.show ();
                    main_stack.set_visible_child_name ("pickers");
                    break;
                case 1:
                    home_button.show ();
                    main_stack.set_visible_child_name ("sourcelist");
                    break;
                case 2:
                    home_button.show ();
                    main_stack.set_visible_child_name ("modebutton");
                    break;
                case 3:
                    home_button.show ();
                    main_stack.set_visible_child_name ("dynamictab");
                    break;
                case 4:
                    home_button.show ();
                    main_stack.set_visible_child_name ("alert");
                    break;
                case 5:
                    home_button.show ();
                    main_stack.set_visible_child_name ("storage");
                    break;
                case 6:
                    home_button.show ();
                    main_stack.set_visible_child_name ("toasts");
                    break;
            }
        });
        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (welcome);
        main_stack.add_named (scrolled, "welcome");
    }

    private void create_sourcelist () {
        var label = new Gtk.Label ("No selected item");
        var source_list = new Granite.Widgets.SourceList ();

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (source_list, false, false);
        paned.add2 (label);
        paned.position = 150;

        var rand = new GLib.Rand ();
        for (int letter = 'A'; letter <= 'Z'; letter++) {
            var expandable_letter = new Granite.Widgets.SourceList.ExpandableItem ("Item %c".printf (letter));
            source_list.root.add (expandable_letter);
            for (int number = 1; number <= 10; number++) {
                var number_item = new Granite.Widgets.SourceList.Item ("Subitem %d".printf (number));
                var val = rand.next_int ();
                if (val % 7 == 0)
                    number_item.badge = "1";
                expandable_letter.add (number_item);
            }
        }

        main_stack.add_named (paned, "sourcelist");

        source_list.item_selected.connect ((item) => {
            if (item == null) {
                label.label = "No selected item";
                return;
            }

            if (item.badge != "" && item.badge != null)
                item.badge = "";
            label.label = "%s - %s".printf (item.parent.name, item.name);
        });
    }

    private void create_toast () {
        var toast = new Granite.Widgets.Toast (_("Button was pressed!"));
        toast.set_default_action (_("Do Things"));

        var button = new Gtk.Button.with_label (_("Press Me"));

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.margin = 24;
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.row_spacing = 6;
        grid.add (button);

        var overlay = new Gtk.Overlay ();
        overlay.add_overlay (grid);
        overlay.add_overlay (toast);
        
        main_stack.add_named (overlay, "toasts");

        button.clicked.connect (() => {
            toast.send_notification ();
        });

        toast.default_action.connect (() => {
            var label = new Gtk.Label (_("Did The Thing"));
            toast.title = _("Already did the thing");
            toast.set_default_action (null);
            grid.add (label);
            grid.show_all ();
        });
    }

    private void create_modebutton () {
        var grid = new Gtk.Grid ();
        grid.row_spacing = 6;
        grid.column_spacing = 12;
        var icon_mode = new Granite.Widgets.ModeButton ();
        icon_mode.append_icon ("view-grid-symbolic", Gtk.IconSize.BUTTON);
        icon_mode.append_icon ("view-list-symbolic", Gtk.IconSize.BUTTON);
        icon_mode.append_icon ("view-column-symbolic", Gtk.IconSize.BUTTON);
        var text_mode = new Granite.Widgets.ModeButton ();
        text_mode.append_text ("Foo");
        text_mode.append_text ("Bar");
        var expandable_grid_start = new Gtk.Grid ();
        expandable_grid_start.expand = true;
        var expandable_grid_end = new Gtk.Grid ();
        expandable_grid_end.expand = true;
        var clear_button = new Gtk.Button.with_label("Clear Selected");
        clear_button.clicked.connect (() => {
            icon_mode.selected = -1;
            text_mode.selected = -1;
        });
        grid.attach (expandable_grid_start, 0, 0, 1, 1);
        grid.attach (expandable_grid_end, 2, 4, 1, 1);
        grid.attach (icon_mode, 1, 1, 1, 1);
        grid.attach (text_mode, 1, 2, 1, 1);
        grid.attach (clear_button, 1, 3, 1 ,1);
        main_stack.add_named (grid, "modebutton");
    }

    private void create_alert () {
        var alert = new Granite.Widgets.AlertView ("Nothing here", "Maybe you can enable <b>something</b> to hide it but <i>otherwise</i> it will stay here", "dialog-warning");
        main_stack.add_named (alert, "alert");
        alert.show_action ("Hide this button");
        alert.action_activated.connect (() => {alert.hide_action ();});
    }

    private void create_storage () {
        var grid = new Gtk.Grid ();
        grid.row_spacing = 6;
        grid.column_spacing = 12;
        var file_root = GLib.File.new_for_path ("/");
        try {
            var info = file_root.query_filesystem_info (GLib.FileAttribute.FILESYSTEM_SIZE, null);
            var size = info.get_attribute_uint64 (GLib.FileAttribute.FILESYSTEM_SIZE);
            var storage = new Granite.Widgets.StorageBar.with_total_usage (size, size/2);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.AUDIO, size/40);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.VIDEO, size/30);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.APP, size/20);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.PHOTO, size/10);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.FILES, size/5);
            grid.add (storage);
        } catch (Error e) {
            critical (e.message);
        }

        main_stack.add_named (grid, "storage");
    }

    int i;
    private void create_dynamictab () {
        var notebook = new Granite.Widgets.DynamicNotebook ();
        notebook.expand = true;
        for (i = 1; i <= 6; i++) {
            var page = new Gtk.Label ("Page %d".printf (i));
            var tab = new Granite.Widgets.Tab ("Tab %d".printf (i), new ThemedIcon ("mail-mark-important-symbolic"), page);
            notebook.insert_tab (tab, i-1);
        }
        main_stack.add_named (notebook, "dynamictab");

        notebook.new_tab_requested.connect (() => {
            var page = new Gtk.Label ("Page %d".printf (i));
            var tab = new Granite.Widgets.Tab ("Tab %d".printf (i), new ThemedIcon ("mail-mark-important-symbolic"), page);
            notebook.insert_tab (tab, i-1);
            i++;
        });
    }

    private Granite.Widgets.Avatar create_avatar () {
        var username = GLib.Environment.get_user_name ();
        var avatar = new Granite.Widgets.Avatar ();
        var iconfile = @"/var/lib/AccountsService/icons/$username";

        avatar.valign = Gtk.Align.CENTER;

        try {
            var pixbuf = new Gdk.Pixbuf.from_file (iconfile);
            avatar.pixbuf = pixbuf.scale_simple (24, 24, Gdk.InterpType.BILINEAR);
            avatar.set_tooltip_text ("Avatar widget: User image found");
        } catch (Error e) {
            avatar.show_default (24);
            avatar.set_tooltip_text ("Avatar widget: User image not found, using fallback");
        }

        return avatar;
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();
        return application.run (args);
    }
}
