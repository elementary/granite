/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

public class Granite.SwipeTracker : Object {
    // This signal is emitted right before a swipe will be started
    public signal void begin_swipe ();

    // This signal is emitted every time the progress value changes.
    public signal void update_swipe (double progress);

    // This signal is emitted as soon as the gesture has stopped.
    public signal void end_swipe ();

    private const int TOUCHPAD_BASE_DISTANCE_H = 400;
    // private const int TOUCHPAD_BASE_DISTANCE_V = 300;

    // The widget that accepts the swipe event
    public unowned Gtk.Widget swipeable { get; construct; }

    // How completed the swipe is
    private double progress;
    private double prev_offset = 0;

    public Gtk.GestureDrag drag_gesture;

    public SwipeTracker (Gtk.Widget swipeable) {
        Object (swipeable: swipeable);
    }

    construct {
        drag_gesture = new Gtk.GestureDrag ();
        drag_gesture.drag_begin.connect (on_drag_begin);
        drag_gesture.drag_update.connect (on_drag_update);
        drag_gesture.drag_end.connect (on_drag_end);

        swipeable.add_controller (drag_gesture);
    }

    ~SwipeTracker () {
        swipeable.remove_controller (drag_gesture);
    }

    private void on_drag_begin () {
        prev_offset = 0;
        progress = 0;
        begin_swipe ();
    }

    private void on_drag_update (Gtk.Gesture gesture, double offset_x, double offset_y) {
        double delta, offset;

        offset = offset_x;
        delta = offset - prev_offset;
        prev_offset = offset;

        progress += delta / TOUCHPAD_BASE_DISTANCE_H;
        progress = progress.clamp (-1, 1);

        update_swipe (progress);
    }

    private void on_drag_end () {
        end_swipe ();
    }
}
