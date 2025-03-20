/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
    private static bool initialized = false;
    private static Gtk.CssProvider? granite_base_provider = null;
    private static Gtk.CssProvider? granite_dark_provider = null;
#if INCLUDE_GTK_STYLESHEETS
    private static Gtk.CssProvider? gtk_base_provider = null;
    private static Gtk.CssProvider? gtk_dark_provider = null;
#endif
    private static Gtk.CssProvider? app_provider = null;

    /**
     * Initializes Granite.
     * If Granite has already been initialized, the function will return.
     * Makes sure translations and types for Granite are set up properly.
     * @since 7.2.0
     */
    [Version (since = "7.2.0")]
    public void init () {
        if (initialized) {
            return;
        }

        typeof (Granite.Settings).ensure ();

        unowned var display_manager = Gdk.DisplayManager.@get ();
        display_manager.display_opened.connect (register_display);

        foreach (unowned var display in display_manager.list_displays ()) {
            register_display (display);
        }

        GLib.Intl.bindtextdomain (Granite.GETTEXT_PACKAGE, Granite.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (Granite.GETTEXT_PACKAGE, "UTF-8");
        initialized = true;
    }

    private static void register_display (Gdk.Display display) {
        var gtk_settings = Gtk.Settings.get_for_display (display);
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            set_provider_for_display (display, gtk_settings.gtk_application_prefer_dark_theme);
        });

        set_provider_for_display (display, gtk_settings.gtk_application_prefer_dark_theme);

        var icon_theme = Gtk.IconTheme.get_for_display (display);
        icon_theme.add_resource_path ("/io/elementary/granite");
    }

    private static void set_provider_for_display (Gdk.Display display, bool prefer_dark_style) {
        if (app_provider == null) {
            var base_path = Application.get_default ().resource_base_path;
            if (base_path != null) {
                var base_uri = "resource://" + base_path;
                var base_file = File.new_for_uri (base_uri);

                app_provider = init_provider_from_file (base_file.get_child ("Application.css"));
            }

            if (app_provider != null) {
                Gtk.StyleContext.add_provider_for_display (display, app_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            }
        }

        if (prefer_dark_style) {
            if (granite_base_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, granite_base_provider);
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_base_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, gtk_base_provider);
            }
#endif

            if (granite_dark_provider == null) {
                granite_dark_provider = new Gtk.CssProvider ();
                granite_dark_provider.load_from_resource ("/io/elementary/granite/Granite-dark.css");
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_dark_provider == null) {
                gtk_dark_provider = new Gtk.CssProvider ();
                gtk_dark_provider.load_from_resource ("/io/elementary/granite/Gtk-dark.css");
            }
#endif

            Gtk.StyleContext.add_provider_for_display (display, granite_dark_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
#if INCLUDE_GTK_STYLESHEETS
            Gtk.StyleContext.add_provider_for_display (display, gtk_dark_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
#endif
        } else {
            if (granite_dark_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, granite_dark_provider);
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_dark_provider != null) { 
                Gtk.StyleContext.remove_provider_for_display (display, gtk_dark_provider);
            }
#endif

            if (granite_base_provider == null) {
                granite_base_provider = new Gtk.CssProvider ();
                granite_base_provider.load_from_resource ("/io/elementary/granite/Granite.css");
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_base_provider == null) {
                gtk_base_provider = new Gtk.CssProvider ();
                gtk_base_provider.load_from_resource ("/io/elementary/granite/Gtk.css");
            }
#endif

            Gtk.StyleContext.add_provider_for_display (display, granite_base_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
#if INCLUDE_GTK_STYLESHEETS
            Gtk.StyleContext.add_provider_for_display (display, gtk_base_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
#endif
        }
    }

    private static Gtk.CssProvider? init_provider_from_file (File file) {
        if (file.query_exists ()) {
            var provider = new Gtk.CssProvider ();
            provider.load_from_file (file);

            return provider;
        }

        return null;
    }
}
