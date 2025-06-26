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

public class Granite.SwipeTracker : Object {
    // private const int TOUCHPAD_BASE_DISTANCE_H = 400;
    // private const int TOUCHPAD_BASE_DISTANCE_V = 300;

    // The widget that accepts the swipe event
    public unowned Gtk.Widget widget { get; construct; }

    // How completed the swipe is
    public double progress { get; set; }

    private double prev_offset = 0;

    public Gtk.GestureDrag drag_gesture;

    public SwipeTracker (Gtk.Widget widget) {
        Object (widget: widget);
    }

    construct {
        drag_gesture = new Gtk.GestureDrag ();
        drag_gesture.drag_update.connect (on_drag_update);

        widget.add_controller (drag_gesture);
    }

    ~SwipeTracker () {
        widget.remove_controller (drag_gesture);
    }

    public void on_drag_update (Gtk.Gesture gesture, double offset_x, double offset_y) {
        double delta, offset;

        offset = offset_x;
        delta = offset - prev_offset;
        prev_offset = offset;

        progress += delta / 100;
        progress = progress.clamp (-1, 1);
    }
}
