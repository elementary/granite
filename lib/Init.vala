/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
    private static bool initialized = false;

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

        Granite.StyleManager.get_instance (); // Make sure everything is being set up there

        GLib.Intl.bindtextdomain (Granite.GETTEXT_PACKAGE, Granite.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (Granite.GETTEXT_PACKAGE, "UTF-8");
        initialized = true;
    }
}
