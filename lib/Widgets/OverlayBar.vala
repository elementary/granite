/*
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
public class Granite.Widgets.OverlayBar : Gtk.EventBox {

    private const string FALLBACK_THEME = """
        .overlay-bar {
            background-color: alpha (#333, 0.8);
            border-radius: 3px;
            border-width: 0;
            box-shadow:
                0 1px 3px alpha (#000, 0.12),
                0 1px 2px alpha (#000, 0.24);
            color: #fff;
            padding: 3px 6px;
            margin: 6px;
            text-shadow: 0 1px 2px alpha (#000, 0.6);
        }
    """;

    private Gtk.Label status_label;
    private Gtk.Revealer revealer;
    private Gtk.Spinner spinner;

    /**
     * overlay: Deprecated property, always returns null.
     */
    [Version (deprecated = true, deprecated_since = "0.5.1", replacement = "")]
    public Gtk.Overlay? overlay { get; construct; }

    /**
     * Status text displayed inside the Overlay Bar.
     */
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "OverlayBar.label")]
    public string status {
        set {
           status_label.label = value;
        }

        get {
            return status_label.label;
        }
    }

    /**
     * Text displayed inside the Overlay Bar.
     */
    public string label {
        get {
            return status_label.label;
        }
        set {
           status_label.label = value;
        }
    }

    /**
     * Whether to display a {@link Gtk.Spinner} inside the Overlay Bar.
     */
    public bool active {
        get {
            return spinner.active;
        }
        set {
            spinner.active = value;
            revealer.reveal_child = value;
        }
    }
    /**
     * Create a new Overlay Bar, and add it to the {@link Gtk.Overlay}.
     */
    public OverlayBar (Gtk.Overlay? overlay = null) {
        if (overlay != null) {
            overlay.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK);
            overlay.add_overlay (this);
        }
    }

    construct {
        overlay = null;
        status_label = new Gtk.Label ("");
        status_label.set_ellipsize (Pango.EllipsizeMode.END);

        spinner = new Gtk.Spinner ();

        revealer = new Gtk.Revealer ();
        revealer.reveal_child = false;
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        revealer.add (spinner);

        var grid = new Gtk.Grid ();
        grid.add (status_label);
        grid.add (revealer);

        add (grid);

        set_halign (Gtk.Align.END);
        set_valign (Gtk.Align.END);

        int priority = Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK;
        Granite.Widgets.Utils.set_theming (grid, FALLBACK_THEME, StyleClass.OVERLAY_BAR, priority);

        var ctx = grid.get_style_context ();
        var state = ctx.get_state ();

        var padding = ctx.get_padding (state);
        status_label.margin_top = padding.top;
        status_label.margin_bottom = padding.bottom;
        status_label.margin_start = padding.left;
        status_label.margin_end = padding.right;
        spinner.margin_end = padding.right;

        var margin = ctx.get_margin (state);
        grid.margin_top = margin.top;
        grid.margin_bottom = margin.bottom;
        grid.margin_start = margin.left;
        grid.margin_end = margin.right;
    }

    public override void parent_set (Gtk.Widget? old_parent) {
        Gtk.Widget parent = get_parent ();

        if (old_parent != null)
            old_parent.enter_notify_event.disconnect (enter_notify_callback);
        if (parent != null)
            parent.enter_notify_event.connect (enter_notify_callback);
    }

    private bool enter_notify_callback (Gdk.EventCrossing event) {
        if (get_halign () == Gtk.Align.START)
            set_halign (Gtk.Align.END);
        else
            set_halign (Gtk.Align.START);

        queue_resize ();

        return false;
    }
}
