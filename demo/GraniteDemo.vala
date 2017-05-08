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

        create_headerbar ();

        var alert_view = new AlertViewView ();
        var avatar_view = new AvatarView ();
        var css_view = new CSSView (window);
        var date_time_picker_view = new DateTimePickerView ();
        var dynamic_notebook_view = new DynamicNotebookView ();
        var mode_button_view = new ModeButtonView ();
        var overlaybar_view = new OverlayBarView ();
        var source_list_view = new SourceListView ();
        var storage_view = new StorageView ();
        var toast_view = new ToastView ()
        var welcome = new WelcomeView ();

        var main_stack = new Gtk.Stack ();
        main_stack.add_titled (welcome, "welcome", "Welcome");
        main_stack.add_titled (alert_view, "alert", "AlertView");
        main_stack.add_titled (avatar_view, "avatar", "Avatar");
        main_stack.add_titled (css_view, "css", "Style Classes");
        main_stack.add_titled (date_time_picker_view, "pickers", "DatePicker & TimePicker");
        main_stack.add_titled (dynamic_notebook_view, "dynamictab", "DynamicNotebook");
        main_stack.add_titled (mode_button_view, "modebutton", "ModeButton");
        main_stack.add_titled (overlaybar_view, "overlaybar", "OverlayBar");
        main_stack.add_titled (source_list_view, "sourcelist", "SourceList");
        main_stack.add_titled (storage_view, "storage", "StorageBar");
        main_stack.add_titled (toast_view, "toasts", "Toast");

        var stack_sidebar = new Gtk.StackSidebar ();
        stack_sidebar.stack = main_stack;

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.add1 (stack_sidebar);
        paned.add2 (main_stack);

        window.add (paned);
        window.set_default_size (800, 550);
        window.show_all ();
    }

    private void create_headerbar () {
        var headerbar = new Gtk.HeaderBar ();
        headerbar.title = "Granite";
        headerbar.subtitle = "Demo Window";
        headerbar.show_close_button = true;

        var about_button = new Gtk.Button.from_icon_name ("dialog-information", Gtk.IconSize.LARGE_TOOLBAR);
        about_button.tooltip_text = "About this application";
        about_button.clicked.connect (() => {show_about (window);});

        headerbar.pack_end (about_button);
        window.set_titlebar (headerbar);
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();
        return application.run (args);
    }
}
