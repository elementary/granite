/*
 * Copyright 2025 elementary, Inc. <https://elementary.io>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * This interface is used for asking window manager to provide background blur for the surface.
 */
public interface Granite.BlurSurface : Gtk.Widget, Gtk.Native {
    /**
     * Returns whether application is running with Wayland backend
     */
    public bool is_wayland () {
        return Gdk.Display.get_default () is Gdk.Wayland.Display;
    }

    /**
     * Initializes blur support. Uses default `blur_registry_handle_global` and `get_x11_blur_hints`.
     * Use if you are not using other Wayland/X11 protocols.
     */
    public void simple_blur_init () {
        if (is_wayland ()) {
            init_wayland (blur_registry_handle_global);
        } else {
            update_x11_hints (get_x11_blur_hints (0, 0, 0, 0, 0));
        }
    }

    private static Wl.RegistryListener registry_listener;

    /**
     * Initializes blur support on Wayland.
     * Use this method only if you need to manually initialize support of multiple
     * Wayland protocols. Otherwise use `simple_blur_init`.
     */
    public void init_wayland (Wl.RegistryListenerGlobal registry_handle_global) requires (is_wayland ()) {
        registry_listener.global = registry_handle_global;
        unowned var display = (Gdk.Wayland.Display) Gdk.Display.get_default ();
        unowned var wl_display = display.get_wl_display ();
        var wl_registry = wl_display.get_registry ();
        wl_registry.add_listener (
            registry_listener,
            this
        );

        if (wl_display.roundtrip () < 0) {
            return;
        }
    }

    /**
     * Registers the window as user of blur protocol. Use with `init_wayland` method.
     */
    public void blur_registry_handle_global (Wl.Registry wl_registry, uint32 name, string @interface, uint32 version) {
        if (@interface == "io_elementary_pantheon_blur_manager_v1") {
            var blur_manager = wl_registry.bind<PantheonBlur.BlurManager> (name, ref PantheonBlur.BlurManager.iface, uint32.min (version, 1));
            unowned var surface = get_surface ();
            if (surface is Gdk.Wayland.Surface) {
                unowned var wl_surface = ((Gdk.Wayland.Surface) surface).get_wl_surface ();
                set_data ("-pantheon-wayland-blur", blur_manager.get_blur (wl_surface));
            }
        }
    }

    /**
     * Request background blur. Use if you use blur Wayland/X11 protocol only.
     * Otherwise manually request blur using `request_blur_wayland` and `update_x11_hints` with `get_x11_blur_hints`.
     */
    public void simple_request_blur (uint x, uint y, uint width, uint height, uint clip_radius) {
        if (is_wayland ()) {
            request_blur_wayland (x, y, width, height, clip_radius);
        } else {
            update_x11_hints (get_x11_blur_hints (x, y, width, height, clip_radius));
        }
    }

    /**
     * Request background blur on wayland. 
     * Use this method only if you use multiple Wayland protocols. Otherwise use `simple_request_blur`.
     */
    public void request_blur_wayland (uint x, uint y, uint width, uint height, uint clip_radius) {
        if (!is_wayland ()) {
            warning ("BlurSurface.request_blur_wayland: Ignoring, not on Wayland");
        }

        unowned PantheonBlur.Blur? blur = get_data ("-pantheon-wayland-blur");
        if (blur != null) {
            blur.set_region (x, y, width, height, clip_radius);
        } else {
            debug ("Couldn't request blur: Blur surface was null. Did you forget to register blur interface?");
        }
    }

    /**
     * Updates X11 hints that Gala (Pantheon window manager) uses for its protocols for X11 windows.
     * Use only if you support multiple X11 Gala protocols.
     */
    public void update_x11_hints (string value) requires (!is_wayland ()) {
        unowned var display = (Gdk.X11.Display) Gdk.Display.get_default ();
        unowned var xdisplay = display.get_xdisplay ();
        var xid = ((Gdk.X11.Surface) get_surface ()).get_xid ();
        var prop = xdisplay.intern_atom ("_MUTTER_HINTS", false);
        xdisplay.change_property (xid, prop, X.XA_STRING, 8, 0, (uchar[]) value, value.length);
    }

    /**
     * Returns string that can be used in `update_x11_hints` to request blur.
     * Use only if you support multiple X11 Gala protocols.
     */
    public string get_x11_blur_hints (uint x, uint y, uint width, uint height, uint clip_radius) {
        return "blur=%u,%u,%u,%u,%u:".printf (x, y, width, height, clip_radius);
    }
}
