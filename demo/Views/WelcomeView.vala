/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class WelcomeView : Gtk.Grid {
    construct {
        var welcome = new Granite.Widgets.Welcome ("Granite Demo", "This is a demo of the Granite library.");
        welcome.append ("text-x-vala", "Visit Valadoc", "The canonical source for Vala API references.");
        welcome.append ("text-x-source", "Get Granite Source", "Granite's source code is hosted on GitHub.");

        add (welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    try {
                        AppInfo.launch_default_for_uri ("https://valadoc.org/granite/Granite.html", null);
                    } catch (Error e) {
                        warning (e.message);
                    }

                    break;
                case 1:
                    try {
                        AppInfo.launch_default_for_uri ("https://github.com/elementary/granite", null);
                    } catch (Error e) {
                        warning (e.message);
                    }

                    break;
            }
        });
    }
}
