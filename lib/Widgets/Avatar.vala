/*
 *  Copyright (C) 2015 Granite Developers (https://launchpad.net/granite)
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 *
 *  Authored by: Felipe Escoto <felescoto95@hotmail.com>, Rico Tzschichholz <ricotz@ubuntu.com>
 */

/**
 * The Avatar widget allowes to theme & crop images with css BORDER_RADIUS property in the .avatar class.
 *
 */
public class Granite.Widgets.Avatar : Gtk.EventBox {
    private const string DEFAULT_ICON = "avatar-default";
    private const string DEFAULT_STYLE = "avatar";
    private const int EXTRA_MARGIN = 4;
    private bool draw_theme_background = true;

    public Gdk.Pixbuf? pixbuf { get; set; }

    /**
     * Makes new Avatar widget
     *
     */
    public Avatar () {
    }

    /**
    * Creates a new Avatar from the speficied pixbuf
    *
    * @param pixbuf image to be used
    */
    public Avatar.from_pixbuf (Gdk.Pixbuf pixbuf) {
        Object (pixbuf: pixbuf);
    }

    /**
     * Creates a new Avatar from the speficied filepath and icon size
     *
     * @param filepath image to be used
     * @param size to scale the image
     */
    public Avatar.from_file (string filepath, int icon_size) {
        try {
            pixbuf = new Gdk.Pixbuf.from_file_at_scale (filepath, icon_size, icon_size, true);
        } catch (Error e) {
            show_default (icon_size);
        }
    }

    /**
     * Creates a new Avatar with the default icon from theme without applying the css style
     *
     * @param icon_size size of the icon to be loaded
     */
    public Avatar.with_default_icon (int icon_size) {
        show_default (icon_size);
    }

    construct {
        valign = Gtk.Align.CENTER;
        halign = Gtk.Align.CENTER;
        visible_window = false;
        get_style_context ().add_class (DEFAULT_STYLE);

        notify["pixbuf"].connect (refresh_size_request);
    }

    ~Avatar () {
        notify["pixbuf"].disconnect (refresh_size_request);
    }

    private void refresh_size_request () {
        if (pixbuf != null) {
            set_size_request (pixbuf.width + EXTRA_MARGIN * 2, pixbuf.height + EXTRA_MARGIN * 2);
            draw_theme_background = true;
        } else {
            set_size_request (0, 0);
        }

        queue_draw ();
    }

    /**
     * Load the default avatar icon from theme into the widget without applying the css style
     *
     * @param icon_size size of the icon to be loaded
     */
    public void show_default (int icon_size) {
        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
        try {
            pixbuf = icon_theme.load_icon (DEFAULT_ICON, icon_size, 0);
        } catch (Error e) {
            stderr.printf ("Error setting default avatar icon: %s ", e.message);
        }

        draw_theme_background = false;
    }

    public override bool draw (Cairo.Context cr) {
        if (pixbuf == null) {
            return base.draw (cr);
        }

        unowned Gtk.StyleContext style_context = get_style_context ();
        var width = get_allocated_width () - EXTRA_MARGIN * 2;
        var height = get_allocated_height () - EXTRA_MARGIN * 2;

        if (draw_theme_background) {
            var border_radius = style_context.get_property (Gtk.STYLE_PROPERTY_BORDER_RADIUS, Gtk.StateFlags.NORMAL).get_int ();
            var crop_radius = int.min (width / 2, border_radius * width / 100);

            Granite.Drawing.Utilities.cairo_rounded_rectangle (cr, EXTRA_MARGIN, EXTRA_MARGIN, width, height, crop_radius);
            Gdk.cairo_set_source_pixbuf (cr, pixbuf, EXTRA_MARGIN, EXTRA_MARGIN);
            cr.fill_preserve ();
            style_context.render_background (cr, EXTRA_MARGIN, EXTRA_MARGIN, width, height);
            style_context.render_frame (cr, EXTRA_MARGIN, EXTRA_MARGIN, width, height);

        } else {
            Granite.Drawing.Utilities.cairo_rounded_rectangle (cr, EXTRA_MARGIN, EXTRA_MARGIN, width, height, 0);
            Gdk.cairo_set_source_pixbuf (cr, pixbuf, EXTRA_MARGIN, EXTRA_MARGIN);
            cr.fill_preserve ();
        }

        return Gdk.EVENT_STOP;
    }
}
