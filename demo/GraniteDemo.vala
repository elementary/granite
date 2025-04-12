/*
 * Copyright 2011-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Granite.Demo : Gtk.Application {
    construct {
        application_id = "io.elementary.granite.demo";
        flags = ApplicationFlags.FLAGS_NONE;
    }

    public override void startup () {
        Granite.init ();
        base.startup ();

        var quit_action = new GLib.SimpleAction ("quit", null);
        quit_action.activate.connect (quit);

        add_action (quit_action);

        set_accels_for_action ("app.quit", {"<Ctrl>Q"});
    }

    public override void activate () {
        var window = new Gtk.ApplicationWindow (this);

        var box_view = new BoxView ();
        var lists_view = new ListsView ();
        var accel_label_view = new AccelLabelView ();
        var css_view = new CSSView (window);
        var date_time_picker_view = new DateTimePickerView ();
        var form_view = new FormView ();
        var hypertext_view = new HyperTextViewGrid ();
        var controls_view = new ControlsView ();
        var maps_view = new MapsView ();
        var overlaybar_view = new OverlayBarView ();
        var toast_view = new ToastView ();
        var settings_uris_view = new SettingsUrisView ();
        var style_manager_view = new StyleManagerView ();
        var utils_view = new UtilsView ();
        var video_view = new VideoView ();
        var placeholder = new WelcomeView ();
        var dialogs_view = new DialogsView (window);
        var application_view = new ApplicationView ();

        var main_stack = new Gtk.Stack ();
        main_stack.add_titled (placeholder, "placeholder", "Placeholder");
        main_stack.add_titled (box_view, "box", "Box");
        main_stack.add_titled (lists_view, "lists", "Lists");
        main_stack.add_titled (style_manager_view, "style_manager", "StyleManager");
        main_stack.add_titled (accel_label_view, "accel_label", "AccelLabel");
        main_stack.add_titled (css_view, "css", "Style Classes");
        main_stack.add_titled (date_time_picker_view, "pickers", "Date & Time");
        main_stack.add_titled (form_view, "formview", "Forms");
        main_stack.add_titled (hypertext_view, "hypertextview", "HyperTextView");
        main_stack.add_titled (controls_view, "controls", "Controls");
        main_stack.add_titled (maps_view, "maps", "Maps");
        main_stack.add_titled (video_view, "video", video_view.title);
        main_stack.add_titled (overlaybar_view, "overlaybar", "OverlayBar");
        main_stack.add_titled (settings_uris_view, "settings_uris", "Settings URIs");
        main_stack.add_titled (toast_view, "toasts", "Toast");
        main_stack.add_titled (utils_view, "utils", "Utils");
        main_stack.add_titled (dialogs_view, "dialogs", "Dialogs");
        main_stack.add_titled (application_view, "application", "Application");

        var start_header = new Gtk.HeaderBar () {
            show_title_buttons = false,
            title_widget = new Gtk.Label ("")
        };
        start_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        start_header.pack_start (new Gtk.WindowControls (START));

        var stack_sidebar = new Gtk.StackSidebar () {
            stack = main_stack,
            vexpand = true
        };

        var start_box = new Gtk.Box (VERTICAL, 0);
        start_box.append (start_header);
        start_box.append (stack_sidebar);
        start_box.add_css_class (Granite.STYLE_CLASS_SIDEBAR);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            start_child = start_box,
            end_child = main_stack,
            resize_start_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        window.child = paned;
        window.set_default_size (900, 600);
        window.set_size_request (750, 500);
        window.titlebar = new Gtk.Grid () { visible = false };
        window.title = "Granite Demo";

        new Granite.ActionSheet (window);

        add_window (window);
        window.show ();
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();
        return application.run (args);
    }
}
