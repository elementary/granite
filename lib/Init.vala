/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
    private static bool initialized = false;
    private Gtk.CssProvider dark_css_provider;

    /*
    * Initializes Granite.
    * If Granite has already been initialized, the function will return.
    * Makes sure translations and stylesheets for Granite are set up properly.
    */
    public void init () {
        if (initialized) {
            return;
        }

        var base_css_provider = new Gtk.CssProvider ();
        base_css_provider.load_from_resource ("/io/elementary/granite/Base.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), base_css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        dark_css_provider = new Gtk.CssProvider ();
        dark_css_provider.load_from_resource ("/io/elementary/granite/Dark.css");

        var gtk_settings = Gtk.Settings.get_default ();
        load_styles_for_color_scheme (gtk_settings.gtk_application_prefer_dark_theme);
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            load_styles_for_color_scheme (gtk_settings.gtk_application_prefer_dark_theme);
        });

        GLib.Intl.bindtextdomain (Granite.GETTEXT_PACKAGE, Granite.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (Granite.GETTEXT_PACKAGE, "UTF-8");
        initialized = true;
    }

    private void load_styles_for_color_scheme (bool prefer_dark) {
        if (prefer_dark) {
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), dark_css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } else {
            Gtk.StyleContext.remove_provider_for_display (Gdk.Display.get_default (), dark_css_provider);
        }
    }
}
