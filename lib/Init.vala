/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
    private static bool initialized = false;

    private Gtk.StyleProvider base_style_provider;
    private Gtk.StyleProvider dark_style_provider;

    /*
    * Initializes Granite.
    * If Granite has already been initialized, the function will return.
    * Makes sure translations and stylesheets for Granite are set up properly.
    */
    public void init () {
        if (initialized) {
            return;
        }

        // init style providers

        var granite_settings = Granite.Settings.get_default ();
        load_styles_for_color_scheme (granite_settings.prefers_color_scheme);
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            load_styles_for_color_scheme (granite_settings.prefers_color_scheme);
        });

        GLib.Intl.bindtextdomain (Granite.GETTEXT_PACKAGE, Granite.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (Granite.GETTEXT_PACKAGE, "UTF-8");
        initialized = true;
    }

    private void load_styles_for_color_scheme (Settings.ColorScheme color_scheme) {
        if (color_scheme == Settings.ColorScheme.DARK) {
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), dark_style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } else {
            Gtk.StyleContext.remove_provider_for_display (Gdk.Display.get_default (), dark_style_provider);
        }
    }
}
