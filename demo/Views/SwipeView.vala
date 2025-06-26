/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SwipeView : DemoPage {
    // prevent Vala unrefing
    private Granite.SwipeTracker swipe_tracker;

    private Gtk.ProgressBar progressbar;
    private uint spring_timeout = -1;

    construct {
        title = "Multitouch";

        progressbar = new Gtk.ProgressBar () {
            fraction = 0.5
        };

        child = progressbar;

        swipe_tracker = new Granite.SwipeTracker (this);
        swipe_tracker.begin_swipe.connect (on_swipe_begin);
        swipe_tracker.update_swipe.connect (on_swipe_update);
        swipe_tracker.end_swipe.connect (on_swipe_end);
    }

    private void on_swipe_begin () {
        if (spring_timeout != -1) {
            Source.remove (spring_timeout);
            spring_timeout = -1;
        }
    }

    private void on_swipe_update (double progress) {
        progressbar.fraction = progress / 2 + 0.5;
    }

    private void on_swipe_end () {
        double epsilon = 0.05;

        // 60 FPS → 16.67 ms per frame
        spring_timeout = Timeout.add (16, () => {
            if (progressbar.fraction < 0.5 + epsilon && progressbar.fraction > 0.5 - epsilon) {
                progressbar.fraction = 0.5;
                spring_timeout = -1;
                return Source.REMOVE;
            }

            if (progressbar.fraction < 0.5) {
                progressbar.fraction *= 1.1;
            } else {
                progressbar.fraction *= 0.9;
            }

            return Source.CONTINUE;
        });
    }
}
