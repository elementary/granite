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

/**
 * A renderer that draws a number within a bubble.
 *
 * @since 0.2
 */
public class Granite.Widgets.CellRendererNumerable : Gtk.CellRenderer {
    /**
     * The number to render. Nothing is drawn if it is zero.
     */
    public uint count { get; set; default = 0; }

    private Gtk.StyleContext? style_context;

    // Text properties
    private const double TEXT_SCALE = Pango.Scale.SMALL;
    private const Pango.Weight TEXT_WEIGHT = Pango.Weight.SEMIBOLD;
    private const Pango.Alignment TEXT_ALIGNMENT = Pango.Alignment.RIGHT;

    private const int HMARGIN = 0;      // Bubble's horizontal padding
    private const int VMARGIN = 3;      // Bubble's vertical padding
    private const int RADIUS = 10;      // Bubble's border curvature
    private const int TEXT_VMARGIN = 1; // Vertical text margin inside the bubble
    private const int TEXT_HMARGIN = 1; // Horizontal text margin inside the bubble
    private const int LINE_WIDTH = 0;   // Width of border line

    private Gdk.RGBA? background_color;
    private Gdk.RGBA? foreground_color;

    private Pango.Rectangle? text_rect;

    public CellRendererNumerable () {
        set_alignment (0.5f, 0.5f);
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.WIDTH_FOR_HEIGHT;
    }

    public override void get_preferred_height (Gtk.Widget widget,
                                               out int minimum_size,
                                               out int natural_size)
    {
        var test_layout = widget.create_pango_layout (get_text ());
        set_text_attributes (test_layout);

        Pango.Rectangle ink_rect, logical_rect;
        test_layout.get_pixel_extents (out ink_rect, out logical_rect);
        this.text_rect = logical_rect;

        int preferred_height = text_rect.height;

        // Add paddings
        preferred_height += 2 * (VMARGIN + LINE_WIDTH + TEXT_VMARGIN);

        minimum_size = natural_size = preferred_height;
    }

    public override void get_preferred_width_for_height (Gtk.Widget widget, int width,
                                                         out int minimum_width,
                                                         out int natural_width)
    {
        int preferred_width = (text_rect != null) ? text_rect.width : 0;

        // Add paddings
        preferred_width += 2 * (HMARGIN + LINE_WIDTH + TEXT_HMARGIN);

        minimum_width = natural_width = preferred_width;
    }

    public override void render (Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle bg_area,
                                    Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {
        if (count > 1) {
            var style_context = widget.get_style_context ();
            if (style_context != this.style_context)
                update_style (style_context);

            return_if_fail (this.background_color != null && this.foreground_color != null);

            // Compute background's dimensions and coordinates
            int background_x, background_y, background_width, background_height;

            background_x = bg_area.x + HMARGIN;
            background_y = bg_area.y + VMARGIN;

            background_width = bg_area.width - 2 * HMARGIN;
            background_height = bg_area.height - 2 * VMARGIN;

            // Let's start drawing
            Gdk.cairo_set_source_rgba (context, background_color);
            context.set_line_width (LINE_WIDTH);

            Granite.Drawing.Utilities.cairo_rounded_rectangle (context,
                                                               background_x,
                                                               background_y,
                                                               background_width,
                                                               background_height,
                                                               RADIUS);
            context.fill_preserve ();

            Gdk.cairo_set_source_rgba (context, foreground_color);
            context.stroke ();

            // Prepare text layout
            var count_layout = widget.create_pango_layout (get_text ());
            set_text_attributes (count_layout);

            // Center text horizontally and vertically
            Pango.Rectangle ink_rect, logical_rect;
            count_layout.get_pixel_extents (out ink_rect, out logical_rect);

            double x_offset = (cell_area.width - ink_rect.width) / 2.0;
            double y_offset = (cell_area.height - ink_rect.height) / 2.0;
            double text_x = cell_area.x - ink_rect.x + x_offset;
            double text_y = cell_area.y - ink_rect.y + y_offset;

            // Render text
            context.move_to (text_x > 0 ? text_x : 0, text_y > 0 ? text_y : 0);
            Pango.cairo_show_layout (context, count_layout);
        }
    }

    // XXX @deprecated. Not used
    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                      out int x_offset, out int y_offset,
                                      out int width, out int height) {
        x_offset = y_offset = width = height = 0;
    }

    /**
     * Updates the foreground and background colors to use those from the
     * new style context.
     *
     * @param new_style_context new style context. If //null// is passed, it uses
     *                          only updates the colors using the old context
     */
    private void update_style (Gtk.StyleContext? new_style_context) {
        // Discard old context
        if (new_style_context != null) {
            if (style_context != null)
                style_context.changed.disconnect (update_colors);
            style_context = new_style_context;
        }

        return_if_fail (style_context != null);

        Gtk.StateFlags state;
        string theme_name = Gtk.Settings.get_default ().gtk_theme_name ?? "";
        bool invert_colors = false, darken = false;

        if ("elementary" in theme_name || "egtk" in theme_name) {
            state = Gtk.StateFlags.NORMAL;
            invert_colors = true;
        } else {
            state = Gtk.StateFlags.SELECTED
                    | Gtk.StateFlags.FOCUSED
                    | Gtk.StateFlags.PRELIGHT;
            darken = true;
        }

        this.background_color = style_context.get_background_color (state);
        this.foreground_color = style_context.get_color (state);

        if (invert_colors) {
            var tmp_bg = this.background_color;
            this.background_color = this.foreground_color;
            this.foreground_color = tmp_bg;
        }

        if (darken)
            this.background_color = darken_rgba (this.background_color, 0.80);
        else
            this.background_color = brighten_rgba (this.background_color, 0.24);

        style_context.changed.connect (update_colors);
    }

    private void update_colors () {
        update_style (null);
    }

    private string get_text () {
        return count.to_string ();
    }

    private static void set_text_attributes (Pango.Layout layout) {
        var attributes = layout.get_attributes () ?? new Pango.AttrList ();
        attributes.insert (Pango.attr_weight_new (TEXT_WEIGHT));
        attributes.insert (Pango.attr_scale_new (TEXT_SCALE));
        layout.set_attributes (attributes);
        layout.set_alignment (TEXT_ALIGNMENT);
    }

    private static Gdk.RGBA brighten_rgba (Gdk.RGBA orig, double val)
        requires (val > 0 && val <= 1.0) {
        return get_rgba (get_color (orig).brighten_val (val));
    }

    private static Gdk.RGBA darken_rgba (Gdk.RGBA orig, double val)
        requires (val > 0 && val <= 1.0) {
        return get_rgba (get_color (orig).darken_val (val));
    }

    private static Granite.Drawing.Color get_color (Gdk.RGBA orig) {
        return new Granite.Drawing.Color (orig.red, orig.green, orig.blue, orig.alpha);
    }

    private static Gdk.RGBA get_rgba (Granite.Drawing.Color orig) {
        return { orig.R, orig.G, orig.B, orig.A };
    }
}
