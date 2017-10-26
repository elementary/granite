/*
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class PaletteView : Gtk.Grid {
    const Gtk.TargetEntry[] DRAG_TARGETS = {{ "text/uri-list", 0, 0 }};

    const string COLORED_SURFACE = """
        * {
            background: %s;
        }
    """;

    private Gtk.Grid color_box;
    private Gtk.Image image;
    private Gtk.Label drag_label;

    construct {
        Gtk.drag_dest_set (this, Gtk.DestDefaults.MOTION | Gtk.DestDefaults.DROP, DRAG_TARGETS, Gdk.DragAction.COPY);
        drag_data_received.connect (on_drag_data_received);

        image = new Gtk.Image ();
        image.get_style_context ().add_class ("card");
        image.halign = Gtk.Align.CENTER;
        image.height_request = 200;
        image.width_request = 350;
        image.hexpand = true;
        image.margin = 12;

        var card = new Gtk.Overlay ();

        drag_label = new Gtk.Label ("Drop Image Here");
        drag_label.get_style_context ().add_class ("h2");

        var overlay = new Gtk.Overlay ();
        overlay.add (image);
        overlay.add_overlay (drag_label);

        color_box = new Gtk.Grid ();
        color_box.halign = Gtk.Align.CENTER;
        color_box.hexpand = true;

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        grid.add (overlay);
        grid.add (color_box);
        add (grid);
    }

    private void on_drag_data_received (Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData data, uint info, uint time) {
        Gtk.drag_finish (drag_context, true, false, time);
        var file = File.new_for_uri (data.get_uris ()[0]);

        try {
            var pixbuf = new Gdk.Pixbuf.from_file (file.get_path ());
            var palette = new Granite.Drawing.Palette.from_pixbuf (pixbuf);

            var new_width = pixbuf.width / (pixbuf.height / image.get_allocated_height ());
            pixbuf = pixbuf.scale_simple (new_width, image.get_allocated_height (), Gdk.InterpType.BILINEAR);

            image.width_request = pixbuf.width;
            image.set_from_pixbuf (pixbuf);

            drag_label.visible = false;
            drag_label.no_show_all = true;

            set_colors (palette);
        } catch (Error e) {
            warning ("Error on file input: %s", e.message);
        }
    }

    private void set_colors (Granite.Drawing.Palette palette) {
        foreach (var widget in color_box.get_children ()) {
            widget.destroy ();
        }

        add_swatch (palette.dominant_swatch, "Dominant color");
        add_swatch (palette.title_swatch, "Title color");
        add_swatch (palette.body_swatch, "Body color");
        add_swatch (palette.vibrant_swatch, "Vibrant color");
        add_swatch (palette.light_vibrant_swatch, "Light vibrant color");
        add_swatch (palette.dark_vibrant_swatch, "Dark vibrant color");
        add_swatch (palette.muted_swatch, "Muted color");
        add_swatch (palette.dark_muted_swatch, "Dark muted color");

        show_all ();
    }

    private void add_swatch (Granite.Drawing.Palette.Swatch? swatch, string tooltip) {
        if (swatch == null) return;

        var box = new Gtk.EventBox ();
        box.set_size_request (48, 48);
        box.tooltip_text = tooltip;

        try {
            var provider = new Gtk.CssProvider ();
            var context = box.get_style_context ();

            Gdk.RGBA rgba = {swatch.R, swatch.G, swatch.B, swatch.A};

            var css = COLORED_SURFACE.printf (rgba.to_string ());

            provider.load_from_data (css, css.length);
            context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            warning ("Setting swatch color failed: %s", e.message);
        }

        color_box.add (box);
    }
}

