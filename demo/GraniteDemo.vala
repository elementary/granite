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
        app_years = "2011-2017";

        build_version = "0.4.1";
        app_icon = "applications-interfacedesign";
        main_url = "https://github.com/elementary/granite";
        bug_url = "https://github.com/elementary/granite/issues";
        help_url = "https://elementaryos.stackexchange.com/questions/tagged/development";
        translate_url = "https://l10n.elementary.io/projects/desktop/granite";

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

        main_paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        create_headerbar ();

        var alert_view = new AlertViewView ();
        var avatar_view = new AvatarView ();
        var date_time_picker_view = new DateTimePickerView ();
        var dynamic_notebook_view = new DynamicNotebookView ();
        var mode_button_view = new ModeButtonView ();
        var overlaybar_view = new OverlayBarView ();
        var source_list_view = new SourceListView ();
        var storage_view = new StorageView ();
        var toast_view = new ToastView ();

        main_stack = new Gtk.Stack ();
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        create_welcome ();

        main_stack.add_named (alert_view, "alert");
        main_stack.add_named (avatar_view, "avatar");
        main_stack.add_named (date_time_picker_view, "pickers");
        main_stack.add_named (dynamic_notebook_view, "dynamictab");
        main_stack.add_named (mode_button_view, "modebutton");
        main_stack.add_named (overlaybar_view, "overlaybar");
        main_stack.add_named (source_list_view, "sourcelist");
        main_stack.add_named (storage_view, "storage");
        main_stack.add_named (toast_view, "toasts");

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

        var primary_color_button = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });
        primary_color_button.color_set.connect (() => {
            Granite.Widgets.Utils.set_color_primary (window, primary_color_button.rgba);
        });

        headerbar.pack_start (home_button);
        headerbar.pack_end (about_button);
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
        welcome.append ("dialog-information", "OverlayBar", "A floating status bar that displays a single line of text");
        welcome.append ("avatar-default", "Avatar", "A styled avatar from an image ");
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
                case 7:
                    home_button.show ();
                    main_stack.set_visible_child_name ("overlaybar");
                    break;
                case 8:
                    home_button.show ();
                    main_stack.set_visible_child_name ("avatar");
                    break;
            }
        });
        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (welcome);
        main_stack.add_named (scrolled, "welcome");
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();
        return application.run (args);
    }
}
