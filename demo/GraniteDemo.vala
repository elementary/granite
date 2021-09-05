/*
 * Copyright 2011-2018 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Granite.Demo : Gtk.Application {
    construct {
        application_id = "io.elementary.granite.demo";
        flags = ApplicationFlags.FLAGS_NONE;
    }

    public override void activate () {
        var window = new Gtk.Window ();

        var accel_label_view = new AccelLabelView ();
        var alert_view = new AlertViewView ();
        var css_view = new CSSView (window);
        var date_time_picker_view = new DateTimePickerView ();
        var dynamic_notebook_view = new DynamicNotebookView ();
        var form_view = new FormView ();
        var mode_button_view = new ModeButtonView ();
        var overlaybar_view = new OverlayBarView ();
        var seekbar_view = new SeekBarView ();
        var settings_view = new SettingsView ();
        var source_list_view = new SourceListView ();
        var storage_view = new StorageView ();
        var toast_view = new ToastView ();
        var utils_view = new UtilsView ();
        var welcome = new WelcomeView ();
        var dialogs_view = new DialogsView (window);
        var async_image_view = new AsyncImageView ();
        var application_view = new ApplicationView ();

        var main_stack = new Gtk.Stack ();
        main_stack.add_titled (welcome, "welcome", "Welcome");
        main_stack.add_titled (accel_label_view, "accel_label", "AccelLabel");
        main_stack.add_titled (alert_view, "alert", "AlertView");
        main_stack.add_titled (css_view, "css", "Style Classes");
        main_stack.add_titled (date_time_picker_view, "pickers", "Date & Time");
        main_stack.add_titled (dynamic_notebook_view, "dynamictab", "DynamicNotebook");
        main_stack.add_titled (form_view, "formview", "Forms");
        main_stack.add_titled (mode_button_view, "selection_controls", "Selection Controls");
        main_stack.add_titled (overlaybar_view, "overlaybar", "OverlayBar");
        main_stack.add_titled (seekbar_view, "seekbar", "SeekBar");
        main_stack.add_titled (settings_view, "settings", "SettingsSidebar");
        main_stack.add_titled (source_list_view, "sourcelist", "SourceList");
        main_stack.add_titled (storage_view, "storage", "StorageBar");
        main_stack.add_titled (toast_view, "toasts", "Toast");
        main_stack.add_titled (utils_view, "utils", "Utils");
        main_stack.add_titled (dialogs_view, "dialogs", "Dialogs");
        main_stack.add_titled (async_image_view, "asyncimage", "AsyncImage");
        main_stack.add_titled (application_view, "application", "Application");

        var stack_sidebar = new Gtk.StackSidebar ();
        stack_sidebar.stack = main_stack;

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.add1 (stack_sidebar);
        paned.add2 (main_stack);

        var gtk_settings = Gtk.Settings.get_default ();

        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        );
        mode_switch.primary_icon_tooltip_text = ("Light background");
        mode_switch.secondary_icon_tooltip_text = ("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.bind_property ("active", gtk_settings, "gtk-application-prefer-dark-theme", GLib.BindingFlags.BIDIRECTIONAL);

        var granite_settings = Granite.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        var headerbar = new Gtk.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = true;
        headerbar.pack_end (mode_switch);

        window.add (paned);
        window.set_default_size (900, 600);
        window.set_size_request (750, 500);
        window.set_titlebar (headerbar);
        window.title = "Granite Demo";
        window.show_all ();

        add_window (window);

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();
        return application.run (args);
    }
}
