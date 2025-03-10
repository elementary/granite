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
    }

    public override void activate () {
        var window = new Gtk.Window ();

        var accel_label_view = new AccelLabelView ();
        var css_view = new CSSView (window);
        var date_time_picker_view = new DateTimePickerView ();
        var form_view = new FormView ();
        var hypertext_view = new HyperTextViewGrid ();
        var mode_button_view = new ModeButtonView ();
        var overlaybar_view = new OverlayBarView ();
        var toast_view = new ToastView ();
        var settings_uris_view = new SettingsUrisView ();
        var utils_view = new UtilsView ();
        var placeholder = new WelcomeView ();
        var dialogs_view = new DialogsView (window);
        var application_view = new ApplicationView ();

        var main_stack = new Gtk.Stack ();
        main_stack.add_titled (placeholder, "placeholder", "Placeholder");
        main_stack.add_titled (accel_label_view, "accel_label", "AccelLabel");
        main_stack.add_titled (css_view, "css", "Style Classes");
        main_stack.add_titled (date_time_picker_view, "pickers", "Date & Time");
        main_stack.add_titled (form_view, "formview", "Forms");
        main_stack.add_titled (hypertext_view, "hypertextview", "HyperTextView");
        main_stack.add_titled (mode_button_view, "selection_controls", "Selection Controls");
        main_stack.add_titled (overlaybar_view, "overlaybar", "OverlayBar");
        main_stack.add_titled (settings_uris_view, "settings_uris", "Settings URIs");
        main_stack.add_titled (toast_view, "toasts", "Toast");
        main_stack.add_titled (utils_view, "utils", "Utils");
        main_stack.add_titled (dialogs_view, "dialogs", "Dialogs");
        main_stack.add_titled (application_view, "application", "Application");

        var gtk_settings = Gtk.Settings.get_default ();

        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        ) {
            primary_icon_tooltip_text = ("Light background"),
            secondary_icon_tooltip_text = ("Dark background"),
            valign = CENTER
        };
        mode_switch.bind_property ("active", gtk_settings, "gtk-application-prefer-dark-theme", BIDIRECTIONAL);

        var end_header = new Gtk.HeaderBar () {
            show_title_buttons = false
        };
        end_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        end_header.pack_end (new Gtk.WindowControls (END));
        end_header.pack_end (mode_switch);

        var end_box = new Gtk.Box (VERTICAL, 0);
        end_box.append (end_header);
        end_box.append (main_stack);

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
            end_child = end_box,
            resize_start_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        var granite_settings = Granite.Settings.get_default ();
        gtk_settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        window.child = paned;
        window.set_default_size (900, 600);
        window.set_size_request (750, 500);
        window.titlebar = new Gtk.Grid () { visible = false };
        window.title = "Granite Demo";

        add_window (window);
        window.show ();

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();
        return application.run (args);
    }
}
