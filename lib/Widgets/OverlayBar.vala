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
 // TODO: Check events, used to be EventBox
public class Granite.Widgets.OverlayBar : Gtk.Box {

    private const string FALLBACK_THEME = """
        .overlay-bar {
            background-color: alpha(#333, 0.8);
            border-radius: 3px;
            border-width: 0;
            box-shadow:
                0 1px 3px alpha(#000, 0.12),
                0 1px 2px alpha(#000, 0.24);
            color: #fff;
            padding: 3px 6px;
            margin: 6px;
            text-shadow: 0 1px 2px alpha(#000, 0.6);
        }
    """;

    private Gtk.Label status_label;
    private Gtk.Revealer revealer;
    private Gtk.Spinner spinner;

    /**
     * {@link Gtk.Overlay} to add #this to
     */
    public Gtk.Overlay? overlay { get; construct; }

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
            return spinner.spinning;
        }
        set {
            spinner.spinning = value;
            revealer.reveal_child = value;
        }
    }
    /**
     * Create a new Overlay Bar, and add it to the {@link Gtk.Overlay}.
     */
    public OverlayBar (Gtk.Overlay? overlay = null) {
        if (overlay != null) {
            overlay.add_overlay (this);
        }
    }

    construct {
        overlay = null;
        status_label = new Gtk.Label ("");
        status_label.set_ellipsize (Pango.EllipsizeMode.END);

        spinner = new Gtk.Spinner ();

        revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
            child = spinner
        };

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.append (status_label);
        box.append (revealer);

        append (box);

        set_halign (Gtk.Align.END);
        set_valign (Gtk.Align.END);

        var provider = new Gtk.CssProvider ();
        provider.load_from_data ((uint8[])FALLBACK_THEME);

        int priority = Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK;
        var ctx = box.get_style_context ();
        ctx.add_class (STYLE_CLASS_OVERLAY_BAR);
        ctx.add_provider (provider, priority);

        var padding = ctx.get_padding ();
        status_label.margin_top = padding.top;
        status_label.margin_bottom = padding.bottom;
        status_label.margin_start = padding.left;
        status_label.margin_end = padding.right;
        spinner.margin_end = padding.right;

        var margin = ctx.get_margin ();
        box.margin_top = margin.top;
        box.margin_bottom = margin.bottom;
        box.margin_start = margin.left;
        box.margin_end = margin.right;

        var focus_controller = new Gtk.EventControllerMotion ();
        focus_controller.enter.connect (enter_notify_callback);
        add_controller (focus_controller);
    }

    private void enter_notify_callback () {
        if (get_halign () == Gtk.Align.START)
            set_halign (Gtk.Align.END);
        else
            set_halign (Gtk.Align.START);

        queue_resize ();
    }
}
