/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

public class Granite.SwipeTracker : Object {
    private const int TOUCHPAD_BASE_DISTANCE_H = 400;
    // private const int TOUCHPAD_BASE_DISTANCE_V = 300;

    // The widget that accepts the swipe event
    public unowned Gtk.Widget widget { get; construct; }

    // How completed the swipe is
    public double progress { get; set; }

    private double prev_offset = 0;

    private uint spring_timeout = -1;

    public Gtk.GestureDrag drag_gesture;

    public SwipeTracker (Gtk.Widget widget) {
        Object (widget: widget);
    }

    construct {
        drag_gesture = new Gtk.GestureDrag ();
        drag_gesture.drag_begin.connect (on_drag_begin);
        drag_gesture.drag_update.connect (on_drag_update);
        drag_gesture.drag_end.connect (on_drag_end);

        widget.add_controller (drag_gesture);
    }

    ~SwipeTracker () {
        widget.remove_controller (drag_gesture);
    }

    private void on_drag_begin () {
        if (spring_timeout != -1) {
            Source.remove (spring_timeout);
            spring_timeout = -1;
        }
    }

    private void on_drag_update (Gtk.Gesture gesture, double offset_x, double offset_y) {
        double delta, offset;

        offset = offset_x;
        delta = offset - prev_offset;
        prev_offset = offset;

        progress += delta / TOUCHPAD_BASE_DISTANCE_H;
        progress = progress.clamp (-1, 1);
    }

    private void on_drag_end () {
        prev_offset = 0;

        // 60 FPS → 16.67 ms per frame
        spring_timeout = Timeout.add (16, () => {
            if (progress < 0.01 && progress > -0.01) {
                progress = 0;
                spring_timeout = -1;
                return Source.REMOVE;
            }

            progress *= 0.8;

            return Source.CONTINUE;
        });
    }
}
