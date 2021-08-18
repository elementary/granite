/*
 * Copyright 2017–2019 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * AsyncImage is a {@link Gtk.Image} that provides a way to load
 * icons and images asynchronously without blocking the main GTK thread.
 *
 * AsyncImage can be used to improve your GTK interface's performance that
 * has a lot of images to load and populate e.g: the applications menu and
 * an icon chooser.
 *
 * Primarily the {@link Gtk.Image} loads it's surface synchronously and blocks the main GTK thread
 * which can cause significant slow downs and lagging. The AsyncImage is a wrapper for the {@link Gtk.Image}
 * and provides with two main methods: {@link Granite.AsyncImage.set_from_gicon_async} and {@link Granite.AsyncImage.set_from_file_async}.
 *
 * AsyncImage internally operates only on {@link Gdk.Pixbuf} and {@link Cairo.Surface}'s which means that you cannot read valid properties
 * from the main {@link Gtk.Image} like {@link Gtk.Image.icon_name}, {@link Gtk.Image.gicon} or {@link Gtk.Image.file}.
 * The only property which will be set is the final surface: {@link Gtk.Image.surface}.
 *
 * Even though AsyncImage sets only the {@link Gtk.Image.surface}, it automatically detects changes to the underlying {@link Gtk.Widget.scale_factor}
 * and reloads the icon to a new scale factor when it changes. If you request to set an {@link GLib.ThemedIcon} and the icon or GTK theme changes
 * the AsyncImage will also reload it to display the new icon with applied changes.
 *
 * The {@link Granite.AsyncImage.gicon_async} and {@link Granite.AsyncImage.size_async} are properties which reflect
 * the current icon and it's size which will or is currently displayed. Note that those two properties will return
 * meaningful results //''only''// when you call {@link Granite.AsyncImage.set_from_gicon_async} and it's wrappers.
 *
 * AsyncImage has also its own cache for already loaded icons. If you attempt to load the same icon at the same size
 * AsyncImage will look it up and if it's available, will set it immediately.
 *
 * If you want to detect when the image was actually loaded into the {@link Cairo.Surface} you can connect to
 * the {@link GLib.Object.notify} signal for {@link Gtk.Image.surface}.
 */
public class Granite.AsyncImage : Gtk.Image {
    private class CacheEntry {
        public string icon;
        public Cairo.Surface? surface;
        public int size;
        public int scale_factor;

        public CacheEntry (string icon, Cairo.Surface? surface, int size, int scale_factor) {
            this.icon = icon;
            this.surface = surface;
            this.size = size;
            this.scale_factor = scale_factor;
        }
    }

    private static Gee.ArrayList<CacheEntry> cache;

    /**
     * If the image should be loaded when the image is rendered.
     *
     * For more details see {@link Granite.AsyncImage.AsyncImage}.
     */
    public bool load_on_realize { construct; private get; }

    /**
     * If the widget should act as a placeholder when the image is not yet loaded.
     *
     * For more details see {@link Granite.AsyncImage.AsyncImage}.
     */
    public bool auto_size_request { construct; private get; }

    /**
     * The icon that will be or is currently displayed in the image.
     *
     * Note that this property is by default and will be ``null`` if you didn't call the {@link Granite.AsyncImage.set_from_gicon_async} or it's wrappers.
     */
    public Icon? gicon_async { get; private set; default = null; }

    /**
     * The size in pixels of the displayed {@link Granite.AsyncImage.gicon_async}.
     *
     * Note that this property is by default and will be ``-1`` if you didn't call the {@link Granite.AsyncImage.set_from_gicon_async} or it's wrappers.
     */
    public int size_async { get; private set; default = -1; }

    private int current_scale_factor = 1;

    /**
     * Creates a new {@link Granite.AsyncImage} that displays
     * a requested icon or file to display asynchronously.
     *
     * The ``load_on_realize`` boolean parameter specifies if the requested image should load when
     * it's about to render and show. This is useful when you don't want to have the image data
     * loaded into memory immediately after calling {@link Granite.AsyncImage.set_from_gicon_async}.
     * Internally this parameter causes the {@link Granite.AsyncImage} to connect to the {@link Gtk.Widget.realize} signal.
     *
     * ``auto_size_request`` boolean parameter specifies if AsyncImage should allocate initial
     * space when loading the image. This is useful when the image is not yet loaded and the widget
     * should act as a placeholder until the image is loaded. Calling any of the ``set_from`` methods will
     * call the {@link Gtk.Widget.set_size_request} with the passed ``size`` or ``width`` and ``height`` if you called {@link Granite.AsyncImage.set_from_file_async}.
     * When image is loaded and shown the size request is then reset to the original values.
     *
     * @param load_on_realize if ``true`` the image will be loaded when it's rendered, false to load the image immediately
     * @param auto_size_request if the widget should act as a placeholder when the image is not yet loaded
     */
    public AsyncImage (bool load_on_realize = true, bool auto_size_request = true) {
        Object (load_on_realize: load_on_realize, auto_size_request: auto_size_request);
    }

    /**
     * Creates a new {@link Granite.AsyncImage} with the supplied
     * ``icon`` and ``size``. See {@link Granite.AsyncImage.AsyncImage} for more details.
     *
     * This is equivalent to calling {@link Granite.AsyncImage.AsyncImage} and {@link Granite.AsyncImage.set_from_gicon_async}.
     *
     * @param icon the {@link GLib.Icon} to display in the image
     * @param size the size of the icon, ``-1`` to load the default size
     * @param load_on_realize if ``true`` the image will be loaded when it's rendered, false to load the image immediately
     * @param auto_size_request if the widget should act as a placeholder when the image is not yet loaded
     */
    public AsyncImage.from_gicon_async (
        Icon icon,
        int size,
        bool load_on_realize = true,
        bool auto_size_request = true
    ) {
        Object (load_on_realize: load_on_realize, auto_size_request: auto_size_request);
        set_from_gicon_async.begin (icon, size);
    }

    /**
     * Creates a new {@link Granite.AsyncImage} with the supplied
     * ``icon_name`` and {@link Gtk.IconSize}. See {@link Granite.AsyncImage.AsyncImage} for more details.
     *
     * This is equivalent to calling {@link Granite.AsyncImage.AsyncImage} and {@link Granite.AsyncImage.set_from_icon_name_async}.
     *
     * @param icon_name the icon name to display in the image
     * @param icon_size the {@link Gtk.IconSize} as the size for the image
     * @param load_on_realize if ``true`` the image will be loaded when it's rendered, false to load the image immediately
     * @param auto_size_request if the widget should act as a placeholder when the image is not yet loaded
     */
    public AsyncImage.from_icon_name_async (
        string icon_name,
        Gtk.IconSize icon_size,
        bool load_on_realize = true,
        bool auto_size_request = true
    ) {
        Object (load_on_realize: load_on_realize, auto_size_request: auto_size_request);
        set_from_icon_name_async.begin (icon_name, icon_size);
    }

    static construct {
        cache = new Gee.ArrayList<CacheEntry> ();
    }

    construct {
        if (load_on_realize) {
            realize.connect (() => update.begin ());
        }

        style_updated.connect (() => {
            if (get_realized ()) {
                update.begin (true);
            }
        });

        direction_changed.connect (() => update.begin (true));

        notify["scale-factor"].connect (() => {
            if (get_scale_factor () != current_scale_factor) {
                update.begin ();
            }
        });
    }

    /**
     * Sets the image to display an {@link GLib.Icon} with a specified size asynchronously.
     *
     * This method sets the {@link Granite.AsyncImage.gicon_async} and {@link Granite.AsyncImage.size_async} properties
     * and depending on the {@link Granite.AsyncImage.load_on_realize} setting, loads it when the image realizes or
     * loads it immediately.
     *
     * Use {@link GLib.ThemedIcon} or {@link Granite.AsyncImage.set_from_icon_name_async} to load the image
     * from an icon name.
     *
     * If the ``icon`` is a {@link GLib.FileIcon} then the image will be loaded using  the {@link Granite.AsyncImage.set_from_file_async}
     * method with the supplied size for both ``width`` and ``height`` with preserving the aspect ratio of the image.
     *
     * If the {@link Granite.AsyncImage.load_on_realize} is ``true``, the error will never be thrown in this method since
     * the loading will happen internally in the AsyncImage when the {@link Gtk.Widget.realize} signal is invoked.
     * In this case, a warning will be printed with relevant information about a fauilure.
     *
     * @param icon the {@link GLib.Icon} to display in the image
     * @param size the size of the icon, ``0`` will clear the {@link Gtk.Image.pixbuf}, ``-1`` to load the default size
     * @param cancellable the cancellable to stop loading the icon
     *
     * @throws GLib.Error when the the icon was not found or failed to load
     */
    public async void set_from_gicon_async (Icon icon, int size, Cancellable? cancellable = null) throws Error {
        gicon_async = icon;
        size_async = size;

        if (auto_size_request) {
            set_size_request (size, size);
        }

        if (!load_on_realize) {
            try {
                yield set_from_gicon_async_internal (gicon_async, size_async, cancellable, false);
            } catch (Error e) {
                throw e;
            }
        }
    }

    /**
     * A wrapper for {@link Granite.AsyncImage.set_from_gicon_async} to display an icon name.
     *
     * This is a convenience method for setting an icon name with a desired {@link Gtk.IconSize}. Note that you'll not be
     * able to change the icon size afterwards with {@link Gtk.Image.pixel_size} or {@link Gtk.Image.icon_size}. You will
     * have to call one of the {@link Granite.AsyncImage} set_from_ methods to change it's size.
     *
     * See {@link Granite.AsyncImage.set_from_gicon_async} for more details.
     *
     * @param icon_name the icon name to display in the image
     * @param icon_size the {@link Gtk.IconSize} as the size for the image
     * @param cancellable the cancellable to stop loading the icon
     *
     * @throws GLib.Error when the the icon was not found or failed to load
     */
    public async void set_from_icon_name_async (
        string icon_name,
        Gtk.IconSize icon_size,
        Cancellable? cancellable = null
    ) throws Error {
        int width, height;
        if (!Gtk.icon_size_lookup (icon_size, out width, out height)) {
            warning ("Invalid icon size %d", icon_size);
            return;
        }

        try {
            yield set_from_gicon_async (new ThemedIcon (icon_name), int.min (width, height), cancellable);
        } catch (Error e) {
            throw e;
        }
    }

    /**
     * Sets the image to display a {@link GLib.File} with requested width and height.
     *
     * ''Note that this method is not a wrapper to the main'' {@link Granite.AsyncImage.set_from_gicon_async} ''method''. Internally, it only creates
     * a {@link Gdk.Pixbuf} with an {@link GLib.InputStream}, loads it asynchronously and sets the {@link Gtk.Image}'s surface to the result.
     *
     * This method will reset the {@link Granite.AsyncImage.gicon_async} and {@link Granite.AsyncImage.size_async} properties to their
     * default values and will not make the {@link Granite.AsyncImage} update the image when the scale factor or icon theme changes.
     *
     * For the time that the image is loaded, the size request of the AsyncImage will be set to ``width`` and ``height`` if ``auto_size_request`` is set to ``true``
     *
     * @param file the {@link GLib.File} to display in the image
     * @param width the width of the final image, ``-1`` to not constrain the width
     * @param height the height of the final image, ``-1`` to not constrain the height
     * @param preserve_aspect_ratio ``true`` to preserve the image's aspect ratio
     * @param cancellable the cancellable to stop loading the image
     *
     * @throws GLib.Error when the the file was not found or failed to load
     */
    public async void set_from_file_async (
        File file,
        int width,
        int height,
        bool preserve_aspect_ratio,
        Cancellable? cancellable = null
    ) throws Error {
        gicon_async = null;
        size_async = -1;

        if (auto_size_request) {
            set_size_request (width, height);
        }

        try {
            var stream = yield file.read_async ();
            var pixbuf = yield new Gdk.Pixbuf.from_stream_at_scale_async (
                stream,
                width * current_scale_factor,
                height * current_scale_factor,
                preserve_aspect_ratio,
                cancellable
            );
            surface = Gdk.cairo_surface_create_from_pixbuf (pixbuf, current_scale_factor, null);
            reset_size_request ();
        } catch (Error e) {
            reset_size_request ();
            throw e;
        }
    }

    private async void set_from_gicon_async_internal (
        Icon icon,
        int size,
        Cancellable? cancellable = null,
        bool bypass_cache
    ) throws Error {
        current_scale_factor = get_scale_factor ();

        if (size == 0) {
            clear ();
            return;
        } else if (size != -1 && !bypass_cache) {
            string target_icon = icon.to_string ();
            foreach (var entry in cache) {
                if (
                    entry.icon == target_icon &&
                    entry.size == size &&
                    entry.scale_factor == current_scale_factor
                ) {
                    surface = entry.surface;
                    reset_size_request ();
                    return;
                }
            }
        }

        if (icon is FileIcon) {
            try {
                yield set_from_file_async (((FileIcon)icon).file, size, size, true);
            } catch (Error e) {
                throw e;
            }

            return;
        }

        var style_context = get_style_context ();
        var theme = Gtk.IconTheme.get_for_screen (style_context.get_screen ());

        var flags = Gtk.IconLookupFlags.FORCE_SIZE | Gtk.IconLookupFlags.USE_BUILTIN;
        if (Gtk.StateFlags.DIR_RTL in style_context.get_state ()) {
            flags |= Gtk.IconLookupFlags.DIR_RTL;
        } else {
            flags |= Gtk.IconLookupFlags.DIR_LTR;
        }

        var info = theme.lookup_by_gicon_for_scale (icon, size, current_scale_factor, flags);
        if (info == null) {
            reset_size_request ();
            throw new IOError.NOT_FOUND ("Failed to lookup icon \"%s\" at size %i".printf (icon.to_string (), size));
        }

        try {
            Gdk.Pixbuf pixbuf;
            if (info.is_symbolic ()) {
                pixbuf = yield info.load_symbolic_for_context_async (style_context, cancellable);
            } else {
                pixbuf = yield info.load_icon_async ();
            }

            surface = Gdk.cairo_surface_create_from_pixbuf (pixbuf, current_scale_factor, null);
            reset_size_request ();

            var entry = new CacheEntry (icon.to_string (), surface, size, current_scale_factor);
            cache.add (entry);
        } catch (Error e) {
            reset_size_request ();
            throw e;
        }
    }

    private async void update (bool bypass_cache = false) {
        if (gicon_async != null && (gicon_async is ThemedIcon || gicon_async is FileIcon)) {
            try {
                yield set_from_gicon_async_internal (gicon_async, size_async, null, bypass_cache);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    private void reset_size_request () {
        if (auto_size_request) {
            set_size_request (-1, -1);
        }
    }
}
