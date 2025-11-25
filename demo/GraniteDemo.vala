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
        base.startup ();
        // Parent classes need to be initialized before the child.
        Granite.init ();
    }

    public override void activate () {
        var window = new Gtk.Window ();

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
        var utils_view = new UtilsView ();
        var video_view = new VideoView ();
        var placeholder = new WelcomeView ();
        var dialogs_view = new DialogsView (window);
        var application_view = new ApplicationView ();

        var main_stack = new Gtk.Stack () {
            vhomogeneous = false
        };
        main_stack.add_titled (placeholder, "placeholder", "Placeholder");
        main_stack.add_titled (box_view, "box", "Box");
        main_stack.add_titled (lists_view, "lists", "Lists & Grids");
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

        var dont_button = new Gtk.ToggleButton () {
            action_name = "app.color-scheme",
            action_target = new Variant.uint32 (Granite.Settings.ColorScheme.NO_PREFERENCE),
            icon_name = "preferences-system-symbolic",
            tooltip_text = "Follow system setting"
        };

        var force_light = new Gtk.ToggleButton () {
            action_name = "app.color-scheme",
            action_target = new Variant.uint32 (Granite.Settings.ColorScheme.LIGHT),
            group = dont_button,
            icon_name = "display-brightness-symbolic",
            tooltip_text = "Light"
        };

        var force_dark = new Gtk.ToggleButton () {
            action_name = "app.color-scheme",
            action_target = new Variant.uint32 (Granite.Settings.ColorScheme.DARK),
            group = force_light,
            icon_name = "weather-clear-night-symbolic",
            tooltip_text = "Dark"
        };

        var style_box = new Granite.Box (HORIZONTAL, LINKED) {
            homogeneous = true,
            margin_start = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_top = 6
        };
        style_box.append (force_light);
        style_box.append (dont_button);
        style_box.append (force_dark);

        var start_box = new Granite.ToolBox () {
            content = stack_sidebar
        };
        start_box.add_top_bar (start_header);
        start_box.add_bottom_bar (style_box);
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
        window.set_size_request (300, 200);
        window.titlebar = new Gtk.Grid () { visible = false };
        window.title = "Granite Demo";

        add_window (window);
        window.show ();

        var style_manager = Granite.StyleManager.get_default ();

        var style_action = new SimpleAction.stateful ("color-scheme", VariantType.UINT32, new Variant.uint32 (style_manager.color_scheme));
        style_action.activate.connect ((parameter) => {
            style_manager.color_scheme = (Granite.Settings.ColorScheme) parameter.get_uint32 ();
        });

        style_manager.notify ["color-scheme"].connect (() => {
            style_action.set_state (new Variant.uint32 (style_manager.color_scheme));
        });

        add_action (style_action);
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();
        return application.run (args);
    }
}
