/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * A {@link Gtk.Application} subclass that includes Granite initialization and
 * setup for common accelerator actions. 
 * 
 * @since 7.7.0
 */

[Version (since = "7.7.0")]
public class Granite.Application : Gtk.Application {

    public Application () {
        Object (
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);
    }

    public override void startup () {
        Granite.init ();
        base.startup ();

        // Respond to user theme preferences
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.SEttings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == DARK
        );

        granite_settings.noftify["prefers-color-scheme"].connect (() => {
                gtk_settings.gtk_application_prefer_dark_theme = (
                        granite_settings.prefers_color_scheme == DARK
                );
        });

        // Set up common actions
        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});
        quit_action.activate.connect (quit);
    }
}
