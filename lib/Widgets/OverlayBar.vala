/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * Copyright 2012 ammonkey <am.monkeyd@gmail.com>
 * Copyright 2013 Julián Unrrein <junrrein@gmail.com>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * A floating status bar that displays a single line of text.
 *
 * This widget is intended to be used as an overlay for a {@link Gtk.Overlay} and is placed in the
 * bottom-right corner by default. You can change its position like you would do for any overlay
 * widget used in a {@link Gtk.Overlay}.
 *
 * The Overlay Bar displays a single line of text that can be changed using the "status" property.
 *
 * {{../doc/images/OverlayBar.png}}
 *
 * This widget tries to avoid getting in front of the content being displayed inside the {@link Gtk.Overlay}
 * by moving itself horizontally to the opposite side from the current one when the mouse pointer enters
 * the widget.
 *
 * For this widget to function correctly, the event {@link Gdk.EventMask.ENTER_NOTIFY_MASK} must be set
 * for the parent {@link Gtk.Overlay}. Overlay Bar's constructor takes care of this automatically, if
 * the parent is supplied as a parameter, but you have to be careful not to unset the event for
 * the {@link Gtk.Overlay} at a later stage.
 *
 * ''Example''<<BR>>
 * {{{
 * public class OverlayBarView : Gtk.Overlay {
 *     construct {
 *         var button = new Gtk.ToggleButton.with_label ("Show Spinner");
 *
 *         var grid = new Gtk.Grid ();
 *         grid.halign = Gtk.Align.CENTER;
 *         grid.valign = Gtk.Align.CENTER;
 *         grid.add (button);
 *
 *         var overlaybar = new Granite.Widgets.OverlayBar (this);
 *         overlaybar.label = "Hover the OverlayBar to change its position";
 *
 *         add (grid);
 *
 *         button.toggled.connect (() => {
 *             overlaybar.active = button.active;
 *         });
 *     }
 * }
 * }}}
 *
 * @see Gtk.Overlay
 *
 */

public class Granite.OverlayBar : Gtk.Box {
    /**
     * {@link Gtk.Overlay} to add #this to
     */
    public Gtk.Overlay? overlay { get; construct; }

    /**
     * Text displayed inside the Overlay Bar.
     */
    public string label { get; set; }

    /**
     * Whether to display a {@link Gtk.Spinner} inside the Overlay Bar.
     */
    public bool active { get; set; }

    /**
     * Create a new Overlay Bar, and add it to the {@link Gtk.Overlay}.
     */
    public OverlayBar (Gtk.Overlay? overlay = null) {
        if (overlay != null) {
            overlay.add_overlay (this);
        }
    }

    class construct {
        set_css_name ("overlaybar");
    }

    construct {
        overlay = null;

        var status_label = new Gtk.Label ("") {
            ellipsize = Pango.EllipsizeMode.END
        };

        var spinner = new Gtk.Spinner () {
            spinning = true
        };

        var revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
            child = spinner
        };

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.append (status_label);
        box.append (revealer);

        append (box);

        set_halign (Gtk.Align.END);
        set_valign (Gtk.Align.END);

        var focus_controller = new Gtk.EventControllerMotion ();
        focus_controller.enter.connect (enter_notify_callback);
        add_controller (focus_controller);

        bind_property ("active", revealer, "reveal-child");
        bind_property ("label", status_label, "label");
    }

    private void enter_notify_callback () {
        if (halign == Gtk.Align.START) {
            halign = Gtk.Align.END;
        } else {
            halign = Gtk.Align.START;
        }
        queue_resize ();
    }
}
