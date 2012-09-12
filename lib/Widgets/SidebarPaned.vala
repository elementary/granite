// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*
 * Copyright (c) 2012 Granite Developers
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Victor Eduardo <victoreduardm@gmail.com>
 */

public class Granite.Widgets.SidebarPaned : Gtk.EventBox, Gtk.Orientable {

    protected Gtk.Paned paned { get; private set; }
    private Gtk.Overlay overlay;
    private Gtk.EventBox handle;
    private bool on_resize_mode = false;

    static const string STYLE_PROP_HANDLE_SIZE = "handle-size";

    protected int handle_size {
        get {
            int size;
            style_get (STYLE_PROP_HANDLE_SIZE, out size);
            return size;
        }
    }

    static construct {
        install_style_property (new ParamSpecInt (STYLE_PROP_HANDLE_SIZE,
                                                  "Handle size",
                                                  "Width of the invisible handle",
                                                  1, 50, 12,
                                                  ParamFlags.READABLE));
    }

    /**
     * PUBLIC API
     */

    public Gtk.Orientation orientation {
        get { return this.paned.orientation; }
        set { set_orientation_internal (value); }
    }

    public int position {
        get { return this.paned.position; }
        set { this.paned.position = value; }
    }

    public bool position_set {
        get { return this.paned.position_set; }
        set { this.paned.position_set = value; }    
    }

    public void pack1 (Gtk.Widget child, bool resize, bool shrink) {
        this.paned.pack1 (child, resize, shrink);
    }

    public void pack2 (Gtk.Widget child, bool resize, bool shrink) {
        this.paned.pack2 (child, resize, shrink);
    }

    public void add1 (Gtk.Widget child) {
        this.paned.add1 (child);
    }

    public void add2 (Gtk.Widget child) {
        this.paned.add2 (child);
    }

    public new void remove (Gtk.Widget widget) {
        this.paned.remove (widget);
    }

    public new void add (Gtk.Widget widget) {
        if (get_child1 () == null)
            add1 (widget);
        else if (get_child2 () == null)
            add2 (widget);
        else
            critical ("Container supports a maximum of two children");
    }

    public unowned Gtk.Widget? get_child1 () {
        return this.paned.get_child1 ();
    }

    public unowned Gtk.Widget? get_child2 () {
        return this.paned.get_child2 ();
    }

    public unowned Gdk.Window get_handle_window () {
        return this.handle.get_window ();
    }

    public new void foreach (Gtk.Callback callback) {
        this.paned.foreach (callback);
    }

    public new void forall (Gtk.Callback callback) {
        this.paned.forall (callback);
    }

    public new void set_direction (Gtk.TextDirection dir) {
        this.paned.set_direction (dir);
        base.set_direction (dir);
        update_virtual_handle_position ();
    }

    public new Gtk.TextDirection get_direction () {
        return this.paned.get_direction ();
    }

    public SidebarPaned () {
        this.paned.get_style_context ().add_class ("sidebar-pane-separator");

        const string DEFAULT_STYLESHEET = """
            .sidebar-pane-separator {
                -GtkPaned-handle-size: 1px;
            }
        """;

        const string FALLBACK_STYLESHEET = """
            GraniteWidgetsSidebarPaned .pane-separator {
                background-color: shade (@bg_color, 0.75);
                border-width: 0;
            }
        """;

        Utils.set_theming (this.paned, DEFAULT_STYLESHEET, "",
                           Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        Utils.set_theming (this.paned, FALLBACK_STYLESHEET, "",
                           Gtk.STYLE_PROVIDER_PRIORITY_THEME);
    }


    /**
     * INTERNALS
     */

    construct {
        push_composite_child ();
        this.overlay = new Gtk.Overlay ();
        this.overlay.set_composite_name ("overlay");
        pop_composite_child ();

        push_composite_child ();
        this.paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        this.paned.set_composite_name ("paned");
        pop_composite_child ();

        this.paned.expand = true;

        Gdk.RGBA transparent = {0, 0, 0, 0};
        overlay.override_background_color (0, transparent);

        setup_handle ();

        this.overlay.add (this.paned);
        base.add (this.overlay);

        this.paned.size_allocate.connect_after (on_paned_size_allocate);

        // The virtual handle will always follow the paned's position
        this.paned.notify["position"].connect (update_virtual_handle_position);
        this.paned.direction_changed.connect (update_virtual_handle_position);

        // We use POINTER_MOTION_HINT_MASK for performance reasons. It reduces the number
        // of motion events received.
        this.add_events (Gdk.EventMask.POINTER_MOTION_MASK
                         | Gdk.EventMask.POINTER_MOTION_HINT_MASK);

        // Set a proper initial status for internal widgets.
        this.position = -1;
        this.orientation = Gtk.Orientation.HORIZONTAL;

        show_all ();
    }

    private void setup_handle () {
        push_composite_child ();
        this.handle = new Gtk.EventBox ();
        this.handle.set_composite_name ("handle");
        pop_composite_child ();

        Gdk.RGBA transparent = {0, 0, 0, 0};
        this.handle.override_background_color (0, transparent);

        overlay.add_overlay (handle);

        this.handle.add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                               | Gdk.EventMask.BUTTON_RELEASE_MASK);

        this.handle.button_press_event.connect (on_handle_button_press);
        this.handle.button_release_event.connect (on_handle_button_release);
        this.handle.grab_broken_event.connect (on_handle_grab_broken);
        this.handle.realize.connect (set_handle_cursor);
    }

    public override bool motion_notify_event (Gdk.EventMotion e) {
        var device = e.device ?? Gtk.get_current_event_device ();

        if (device == null) {
            var display = this.paned.get_display ();

            if (display != null) {
                var dev_manager = display.get_device_manager ();

                if (dev_manager != null)
                    device = dev_manager.list_devices (Gdk.DeviceType.MASTER).nth_data (0);
            }
        }

        if (this.on_resize_mode && device != null) {
            var window = this.paned.get_window ();

            if (window != null) {
                int x, y, pos = 0;
                window.get_device_position (device, out x, out y, null);

                if (this.orientation == Gtk.Orientation.HORIZONTAL)
                    pos = is_ltr () ? x : this.paned.get_allocated_width () - x;
                else
                    pos = y;

                if (this.paned.get_realized () && this.paned.get_mapped () && this.position_set)
                    pos = pos.clamp (this.paned.min_position, this.paned.max_position);

                this.position = pos;
                return true;
            }
        }

        return false;
    }

    private bool is_ltr () {
        var dir = get_direction ();

        if (dir == Gtk.TextDirection.NONE)
            dir = get_default_direction ();

        return dir == Gtk.TextDirection.LTR;
    }

    private void set_orientation_internal (Gtk.Orientation orientation) {
        this.paned.orientation = orientation;
        bool horizontal = orientation == Gtk.Orientation.HORIZONTAL;

        this.handle.hexpand = !horizontal;
        this.handle.vexpand = horizontal;
        this.handle.set_size_request (0, 0);

        if (horizontal) {
            this.handle.margin_top = this.handle.margin_bottom = 0;
            this.handle.halign = Gtk.Align.START;
            this.handle.valign = Gtk.Align.FILL;
        } else {
            this.handle.margin_left = this.handle.margin_right = 0;
            this.handle.halign = Gtk.Align.FILL;
            this.handle.valign = Gtk.Align.START;
        }

        on_paned_size_allocate ();
        update_virtual_handle_position ();

        // Update cursor.
        set_handle_cursor ();
    }

    private void on_paned_size_allocate () {
        int size = this.handle_size;
        bool horizontal = this.orientation == Gtk.Orientation.HORIZONTAL;

        // GtkPaned's handle disappears when one of its children is hidden, destroyed,
        // or simply hasn't been packed yet. The virtual handle reproduces that behavior.
        var paned_handle = this.paned.get_handle_window ();
        if (paned_handle != null) {
            this.handle.visible = paned_handle.is_visible ();
            size += horizontal ? paned_handle.get_width () : paned_handle.get_height ();
        }

        if (horizontal)
            this.handle.set_size_request (size, -1);
        else
            this.handle.set_size_request (-1, size);
    }

    private void update_virtual_handle_position () {
        int new_pos = this.position - this.handle_size / 2;
        new_pos = new_pos > 0 ? new_pos : 0;

        if (this.orientation == Gtk.Orientation.HORIZONTAL) {
            bool is_ltr = is_ltr ();
            this.handle.halign = (is_ltr) ? Gtk.Align.START : Gtk.Align.END;
            this.handle.margin_left = (is_ltr) ? new_pos : 0;
            this.handle.margin_right = (is_ltr) ? 0 : new_pos;
        } else {
            this.handle.margin_top = new_pos;
        }
    }

    private void set_handle_cursor () {
        Gdk.Cursor? arrow_cursor = null;

        var paned_handle_window = this.paned.get_handle_window ();
        if (paned_handle_window != null)
            arrow_cursor = paned_handle_window.get_cursor ();

        var handle_window = this.handle.get_window ();
        if (handle_window != null && handle_window.get_cursor () != arrow_cursor)
            handle_window.set_cursor (arrow_cursor);
    }

    /**
     * Handle's Event Callbacks
     */

    private bool on_handle_button_press (Gdk.EventButton e) {
        if (!this.on_resize_mode && e.button == Gdk.BUTTON_PRIMARY) {
            this.on_resize_mode = true;
            Gtk.grab_add (this.handle);
            return true;
        }

        return false;
    }

    private bool on_handle_button_release (Gdk.EventButton e) {
        this.on_resize_mode = false;
        Gtk.grab_remove (this.handle);
        return true;
    }

    private bool on_handle_grab_broken (Gdk.EventGrabBroken e) {
        this.on_resize_mode = false;
        return true;
    }
}
