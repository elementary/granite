/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SwipeView : DemoPage {
    // prevent Vala unrefing
    private Granite.SwipeTracker swipe_tracker;

    construct {
        title = "Multitouch";

        var progressbar = new Gtk.ProgressBar () {
            fraction = 0.5
        };

        child = progressbar;

        swipe_tracker = new Granite.SwipeTracker (this);
        swipe_tracker.notify["progress"].connect (() => {
            progressbar.fraction = swipe_tracker.progress / 2 + 0.5;
        });
    }
}
