/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Library General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class Granite.Avatar : Gtk.Grid {
    /**
     * The size in pixels to render the widget at. Avatars are always square
     */
    public int pixel_size { get; construct set; }

    /**
     * The file name to load as the avatar image. Used with {@link Gdk.Pixbuf.from_file_at_scale}
     */
    public string? icon_file { get; construct set; }

    /**
     * The full name of the individual (i.e. "John Doe") to use for generating initials
     */
    public string full_name { get; construct set; }

    private Gtk.Label name_label;
    private unowned Gtk.StyleContext overlay_style_context;

    /**
     * Creates a new Avatar from the specified name, pixel size, and optional image file path
     *
     * @param full_name The full name of the individual (i.e. "John Doe")
     * @param pixel_size The size in pixels to render the widget at
     * @param icon_file the file name to load as the avatar image. Used with {@link Gdk.Pixbuf.from_file_at_scale} 
     */
    public Avatar (string full_name, int pixel_size, string? icon_file = null) {
        Object (
            full_name: full_name,
            icon_file: icon_file,
            pixel_size: pixel_size
        );
    }

    /**
     * Creates a new Avatar from a LibFolks Individual and the specified pixel size
     *
     * @param individual The {@link Folks.Individual } to get display name and avatar information from
     * @param pixel_size The size in pixels to render the widget at
     */
    public Avatar.from_individual (Folks.Individual individual, int pixel_size) {
        Object (
            full_name: individual.display_name,
            pixel_size: pixel_size
        );

        if (individual.avatar != null) {
            try {
                individual.avatar.load (pixel_size, null);
                icon_file = individual.avatar.to_string ();
            } catch (Error e) {
                critical (e.message);
            }
        }
    }

    construct {
        set_css_name (Granite.STYLE_CLASS_AVATAR);

        name_label = new Gtk.Label (get_initials ());
        name_label.halign = name_label.valign = Gtk.Align.CENTER;

        var overlay_grid = new AvatarOverlay ();

        overlay_style_context = overlay_grid.get_style_context ();

        var overlay = new Gtk.Overlay ();
        overlay.add (name_label);
        overlay.add_overlay (overlay_grid);

        halign = valign = Gtk.Align.CENTER;
        add (overlay);

        notify["icon-file"].connect (() => {
            queue_draw ();
        });

        notify["full-name"].connect (() => {
            queue_draw ();
        });

        notify["pixel-size"].connect (() => {
            queue_draw ();
        });
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    public override void get_preferred_height_for_width (int width, out int minimum_height, out int natural_height) {
        minimum_height = natural_height = pixel_size;
    }

    public override bool draw (Cairo.Context cr) {
        unowned Gtk.StyleContext style_context = get_style_context ();
        height_request = width_request = pixel_size;

        var border = style_context.get_border (style_context.get_state ());

        if (icon_file == null || icon_file == "") {
            name_label.label = get_initials ();
            name_label.height_request = pixel_size - (border.top + border.bottom);
            name_label.width_request = pixel_size - (border.left + border.right);
            return base.draw (cr);
        }

        try {
            var size = pixel_size * get_scale_factor ();
            var border_radius = style_context.get_property (Gtk.STYLE_PROPERTY_BORDER_RADIUS, style_context.get_state ()).get_int ();
            var crop_radius = int.min (pixel_size / 2, border_radius * pixel_size / 100);

            style_context.render_background (cr, 0, 0, pixel_size, pixel_size);
            style_context.render_frame (cr, 0, 0, pixel_size, pixel_size);

            Granite.Drawing.Utilities.cairo_rounded_rectangle (cr, 0, 0, pixel_size, pixel_size, crop_radius);
            cr.save ();

            var pixbuf = new Gdk.Pixbuf.from_file_at_scale (icon_file, size, size, true);
            cr.scale (1.0 / scale_factor, 1.0 / scale_factor);
            Gdk.cairo_set_source_pixbuf (cr, pixbuf, 0, 0);

            cr.fill_preserve ();
            cr.restore ();

            overlay_style_context.render_background (
                cr,
                border.left, border.top,
                pixel_size - (border.left + border.right), pixel_size - (border.top + border.bottom)
            );
            overlay_style_context.render_frame (
                cr,
                border.left, border.top,
                pixel_size - (border.left + border.right), pixel_size - (border.top + border.bottom)
            );

            name_label.label = "";
        } catch (Error e) {
            critical (e.message);
            return base.draw (cr);
        }

        return Gdk.EVENT_STOP;
    }

    private string get_initials () {
        if (full_name == "" || full_name == null) {
            full_name = "?";
        }

        var names = full_name.split (" ");

        string initials;
        if (names[0].length > 1) {
            initials = names[0].substring (0, 1).up ();
        } else {
            initials = names[0];
        }

        if (names.length > 1) {
            initials += names[names.length - 1].substring (0, 1).up ();
        }

        return (initials);
    }

    // We have to do this so Gtk knows we want this specific grid and not all grids
    private class AvatarOverlay : Gtk.Grid {
        construct {
            set_css_name ("avatar-overlay");
        }
    }
}
